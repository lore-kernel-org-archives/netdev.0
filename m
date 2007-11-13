From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Problem with frame time stamping
Date: Tue, 13 Nov 2007 14:13:31 +0100
Message-ID: <4739A2FB.8030800@cosmosbay.com>
References: <2cbbd8de0711120742h35f27441p5f096e5e99e1d7dc@mail.gmail.com>	 <20071112174759.c2777ea2.dada1@cosmosbay.com>	 <2cbbd8de0711130207t82f2f46h9ee1b876a61bad6a@mail.gmail.com>	 <47397C0C.4060106@cosmosbay.com>	 <2cbbd8de0711130239j67127e1cxf312033aee1ddd5a@mail.gmail.com>	 <473982A7.6040409@cosmosbay.com> <2cbbd8de0711130434s75e78c35rfda90b81686ee9e1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	netfilter-devel@vger.kernel.org, patrik.arlos@bth.se
To: Antoine Zen-Ruffinen <antoine.zen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([80.12.242.50]:24361 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753668AbXKMNNg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 08:13:36 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2303.orange.fr (SMTP Server) with ESMTP id 4B0E71C00093
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 14:13:34 +0100 (CET)
In-Reply-To: <2cbbd8de0711130434s75e78c35rfda90b81686ee9e1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Antoine Zen-Ruffinen a =E9crit :
> THIS is what I did at the beginning. But is seem me to be some thing
> wrong. So I put a static value in skb->tstamp  instead of
> ktime_get_real() for debug purpose. And I was still becoming the
> amount of second, microsecond since 1970. We are back to my initial
> mail ! The value of skb->tsamp doesn't seems to be returned by
> ioctl().
>  =20
OK Antoine.

Yes, 'struct timeval' is as you discovered, ie relative to *something*,=
=20
a given event in the past. (in your case, CLOCK_REALTIME Epoch : Januar=
y=20
1th 1970)

It is even documented (man gettimeofday)

DESCRIPTION
       The  gettimeofday() function shall obtain the current time,=20
expressed as seconds and microseconds since the Epoch, and store it in =
the
       timeval structure pointed to by tp.

=46or timespec STAMPNS, see clock_gettime() description.

clock_gettime(CLOCK_REALTIME, &ts);

If in your driver you stick in tstamp.tv64 a value like 0x00010002, the=
n=20
the result of ioctl(SIOCGSTAMP) will be :
tv.tv_sec =3D 0   (so yes, January 1th 1970)
tv.tv_usec =3D 65   (because 0x10002/1000 =3D 65)

Not counting the fact that .tv64 should not be directly set, unless for=
=20
0 value, because it is not portable.





