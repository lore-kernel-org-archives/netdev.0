From: "Antoine Zen-Ruffinen" <antoine.zen@gmail.com>
Subject: Re: Problem with frame time stamping
Date: Tue, 13 Nov 2007 15:46:09 +0100
Message-ID: <2cbbd8de0711130646t3af4440em46e7f0a61eb4ecf1@mail.gmail.com>
References: <2cbbd8de0711120742h35f27441p5f096e5e99e1d7dc@mail.gmail.com>
	 <20071112174759.c2777ea2.dada1@cosmosbay.com>
	 <2cbbd8de0711130207t82f2f46h9ee1b876a61bad6a@mail.gmail.com>
	 <47397C0C.4060106@cosmosbay.com>
	 <2cbbd8de0711130239j67127e1cxf312033aee1ddd5a@mail.gmail.com>
	 <473982A7.6040409@cosmosbay.com>
	 <2cbbd8de0711130434s75e78c35rfda90b81686ee9e1@mail.gmail.com>
	 <4739A2FB.8030800@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	netfilter-devel@vger.kernel.org, patrik.arlos@bth.se
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <4739A2FB.8030800@cosmosbay.com>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ok, I now understood where my error was.  It was a mismatch between my
old kernel headers and my new kernel that I am running !!!! Pretty
stupid !

Tank's you for your time, you learn me some stuff, I appreciate it.

Antoine

2007/11/13, Eric Dumazet <dada1@cosmosbay.com>:
> Antoine Zen-Ruffinen a =E9crit :
> > THIS is what I did at the beginning. But is seem me to be some thin=
g
> > wrong. So I put a static value in skb->tstamp  instead of
> > ktime_get_real() for debug purpose. And I was still becoming the
> > amount of second, microsecond since 1970. We are back to my initial
> > mail ! The value of skb->tsamp doesn't seems to be returned by
> > ioctl().
> >
> OK Antoine.
>
> Yes, 'struct timeval' is as you discovered, ie relative to *something=
*,
> a given event in the past. (in your case, CLOCK_REALTIME Epoch : Janu=
ary
> 1th 1970)
>
> It is even documented (man gettimeofday)
>
> DESCRIPTION
>        The  gettimeofday() function shall obtain the current time,
> expressed as seconds and microseconds since the Epoch, and store it i=
n the
>        timeval structure pointed to by tp.
>
> For timespec STAMPNS, see clock_gettime() description.
>
> clock_gettime(CLOCK_REALTIME, &ts);
>
> If in your driver you stick in tstamp.tv64 a value like 0x00010002, t=
hen
> the result of ioctl(SIOCGSTAMP) will be :
> tv.tv_sec =3D 0   (so yes, January 1th 1970)
> tv.tv_usec =3D 65   (because 0x10002/1000 =3D 65)
>
> Not counting the fact that .tv64 should not be directly set, unless f=
or
> 0 value, because it is not portable.
>
>
>
>
>
>
