From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Tue, 16 Sep 2008 11:24:11 -0300
Message-ID: <20080916112411.062fa615@tux>
References: <20080819213417.45133573@tux>
	<Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
	<20080822183224.2d52f16c@tux>
	<20080822.143709.65615512.davem@davemloft.net>
	<20080823111446.06a350a2@tux>
	<Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
	<20080824163843.33b4f890@tux>
	<Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
	<20080826141812.589848a0@tux>
	<Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
	<20080828184919.611dd578@tux>
	<Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi>
	<20080830035650.42be37d7@tux>
	<Pine.LNX.4.64.0808301000180.12388@wrl-59.cs.helsinki.fi>
	<20080907051718.58bf133d@tux>
	<Pine.LNX.4.64.0809071341310.8991@wrl-59.cs.helsinki.fi>
	<20080908172043.0d25a427@tux>
	<Pine.LNX.4.64.0809100942370.24708@wrl-59.cs.helsinki.fi>
	<20080911143006.2f516569@tux>
	<Pine.LNX.4.64.0809112140250.26799@wrl-59.cs.helsinki.fi>
	<20080913203117.2a55ea2c@tux>
	<Pine.LNX.4.64.0809140722460.17271@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:42034 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbYIPOYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 10:24:22 -0400
Received: by an-out-0708.google.com with SMTP id d40so263364and.103
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 07:24:19 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0809140722460.17271@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Sep 2008 15:10:33 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Only thing I know to ask is, do you have any idea if your ntpd is=20
> hard-stepping the time instead of adjusting the clock's rate a bit (t=
he=20
> latter should keep the clock monotonious besides potential bugs)?

	I assume it's adjusting the clock's rate a bit. Anyway, it's a
pretty simple config:

fraga@teleporto ~$ cat /etc/ntp.conf=20
server ntp.usp.br
server ntp.nasa.gov
driftfile /etc/ntp.drift

	And ntpd is running without any special parameters.

	The log messages are as simple as:

Sep 15 03:56:04 teleporto ntpd[2301]: frequency initialized 5.891 PPM f=
rom /etc/ntp.drift
Sep 15 03:59:25 teleporto ntpd[2304]: frequency initialized 5.891 PPM f=
rom /etc/ntp.drift
Sep 15 04:03:49 teleporto ntpd[2304]: synchronized to 143.107.255.15, s=
tratum 2
Sep 15 04:03:49 teleporto ntpd[2304]: kernel time sync status change 00=
01
Sep 15 04:10:16 teleporto ntpd[2304]: synchronized to 198.123.30.132, s=
tratum 1
Sep 15 04:11:58 teleporto ntpd[2301]: frequency initialized 5.891 PPM f=
rom /etc/ntp.drift
Sep 15 04:16:18 teleporto ntpd[2301]: synchronized to 198.123.30.132, s=
tratum 1
Sep 15 04:16:18 teleporto ntpd[2301]: kernel time sync status change 00=
01
Sep 15 12:08:53 teleporto ntpd[2301]: kernel time sync status change 40=
01
Sep 15 12:34:31 teleporto ntpd[2301]: kernel time sync status change 00=
01
Sep 15 14:34:06 teleporto ntpd[2301]: kernel time sync status change 40=
01
Sep 15 14:51:12 teleporto ntpd[2301]: kernel time sync status change 00=
01=20

	If I understood correctly what do you mean, ntpd adjusts nicely the ti=
me to not=20
cause huge differences in the time.

	And we're reaching the conclusion that the timer code from 2.6.25 and =
above=20
have something wrong, since 2.6.24 and below is ok, which causes those =
stalls.

	But I'll wait some more time to confirm this, although I'm almost sure=
 it's a timer
related bug which has this colateral effect of stalling connections.

	And just a question: do you use ntpd on your own desktop?
=09
	Thank you!

--=20
