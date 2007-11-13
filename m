From: "Antoine Zen-Ruffinen" <antoine.zen@gmail.com>
Subject: Re: Problem with frame time stamping
Date: Tue, 13 Nov 2007 11:39:28 +0100
Message-ID: <2cbbd8de0711130239j67127e1cxf312033aee1ddd5a@mail.gmail.com>
References: <2cbbd8de0711120742h35f27441p5f096e5e99e1d7dc@mail.gmail.com>
	 <20071112174759.c2777ea2.dada1@cosmosbay.com>
	 <2cbbd8de0711130207t82f2f46h9ee1b876a61bad6a@mail.gmail.com>
	 <47397C0C.4060106@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	netfilter-devel@vger.kernel.org, patrik.arlos@bth.se
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47397C0C.4060106@cosmosbay.com>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is exactly my problem : The driver of the network card I am using
(see rt2x00.serialmonkey.com) do the minimum in the hardware interrupt
(not filling skb->tstamp). Then netif_rx() is called later using a
tasklet (also not filling skb->tstamp). As it seem to me (maybe I am
wrong, if so please tell), the elapse time between the actual frame
arrival and the time where netif_rx() do net_timestamp(skb) is not
predicable !?

Else, I would like to thank you to spend time helping me.



2007/11/13, Eric Dumazet <dada1@cosmosbay.com>:
> Antoine Zen-Ruffinen a =E9crit :
> > What does it bring me to have a nanosecond precision if it is not
> > related to the actual arrival of frame time ? As it seem I can feel
> > skb->tstamp with whatever I want, I always become something else us=
ing
> > ioctl(). (I'm using kernel 2.6.23).
> >
> >
> I guess you misunderstood kernel source, because it is related to
> arrival time, more exactly when it was processed by network stack.
> (Beware  modern NICS can delay the rx interrupt by some us (ethtool -=
c
> eth0), so that an interrupt can feed more than one packet to the OS)
>
> Check net/core/dev.c function netif_rx()
>
> {
> ...
>    if (!skb->tstamp.tv64)
>        net_timestamp(skb);
>
> }
>
> So as soon your system as at least one socket 'asking for tsamps',
> netstamp_needed is not null, and net_timestamp() will call __net_time=
stamp()
> wich does :
>
> skb->tstamp =3D ktime_get_real();
>
> So you should not 'feed' tstamp.tv64 and let it being 0, so that
> netif_rx() can do its job.
>
>
>
>
>
>
-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
