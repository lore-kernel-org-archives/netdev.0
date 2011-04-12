From: Jan =?ISO-8859-1?Q?L=FCbbe?= <jluebbe@debian.org>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 16:19:28 +0200
Message-ID: <1302617968.30934.34.camel@polaris.local>
References: <4D9E62D9.5010400@scotdoyle.com>
	 <20110408121700.0aad53fe@nehalam>	<4D9FE5BE.6060600@scotdoyle.com>
	 <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
	 <4DA39330.2030102@scotdoyle.com> <20110411183105.46e86684@nehalam>
	 <4DA3CB4B.9090506@scotdoyle.com> <1302581384.3603.14.camel@edumazet-laptop>
	 <1302582172.3603.18.camel@edumazet-laptop> <4DA3E074.5090603@scotdoyle.com>
	 <1302587490.3603.22.camel@edumazet-laptop> <4DA3F909.5020609@scotdoyle.com>
	 <1302608951.3233.33.camel@edumazet-laptop>
	 <1302613353.30934.22.camel@polaris.local>
	 <1302614145.3233.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Scot Doyle <lkml@scotdoyle.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirius.lasnet.de ([78.47.116.19]:32833 "EHLO sirius.lasnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755767Ab1DLOTg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 10:19:36 -0400
In-Reply-To: <1302614145.3233.47.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-12 at 15:15 +0200, Eric Dumazet wrote:=20
> Le mardi 12 avril 2011 =C3=A0 15:02 +0200, Jan L=C3=BCbbe a =C3=A9cri=
t :
> > Here you check dopt->optlen, which certainly should be 40 at most. =
The
> > calculation of dopt->optlen wasn't changed by my patch, though.
>=20
> Check again the thread Jan.
>=20
> Scot is using a tool (IP Stack Checker's tcpsic) to forge random tcp
> packets.

> Maybe your patch is fine but requires a change in a previous function=
,
> to make sure we deny some crazy packet before generating an ip_option=
s
> with more than 40 bytes, in an icmp_send() reply.

One thing which could expose a problem is that it now will timestamp th=
e
packet in the last 'slot', too. (which it didn't before)

In general, there is not a lot of error-checking in the options stuff.

> I took a look at this ip_options stuff and must say its really hard t=
o
> even _read_ the code. Understanding it might need several days or a n=
ew
> brain ?

It took me some days do even figure out how it is supposed to fit
together...

> I cannot Ack or Nack your patch, I must admit it. Isnt it frightening=
?

David Miller already declared this code as 'officially terrible'...

Your patch should catch those forged packets before more harmful things
can go wrong, but even before my patch, i think forged packets could
cause trouble...

Regards,
Jan

