From: "Matthias Andree" <matthias.andree@gmx.de>
Subject: Re: [PATCH v2] tcp: fix MSG_PEEK race check
Date: Mon, 18 May 2009 17:34:29 +0200
Message-ID: <op.ut4tjrlu1e62zd@balu.cs.uni-paderborn.de>
References: <Pine.LNX.4.64.0905070931590.12068@wrl-59.cs.helsinki.fi>
 <200905092014.35642.elendil@planet.nl>
 <Pine.LNX.4.64.0905110926520.10047@wrl-59.cs.helsinki.fi>
 <20090517.154137.104422195.davem@davemloft.net>
 <Pine.LNX.4.64.0905180958150.3381@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: elendil@planet.nl, Netdev <netdev@vger.kernel.org>
To: =?iso-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:46198 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751140AbZERPeb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2009 11:34:31 -0400
In-Reply-To: <Pine.LNX.4.64.0905180958150.3381@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 18.05.2009, 09:24 Uhr, schrieb Ilpo J=E4rvinen =20
<ilpo.jarvinen@helsinki.fi>:

> On Sun, 17 May 2009, David Miller wrote:
>
>> From: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
>> Date: Mon, 11 May 2009 09:32:34 +0300 (EEST)
>>
>> > [PATCH v2] tcp: fix MSG_PEEK race check
>> >
>> > Commit 518a09ef11 (tcp: Fix recvmsg MSG_PEEK influence of
>> > blocking behavior) lets the loop run longer than the race check
>> > did previously expect, so we need to be more careful with this
>> > check and consider the work we have been doing.
>> >
>> > I tried my best to deal with urg hole madness too which happens
>> > here:
>> > 	if (!sock_flag(sk, SOCK_URGINLINE)) {
>> > 		++*seq;
>> > 		...
>> > by using additional offset by one but I certainly have very
>> > little interest in testing that part.
>> >
>> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>> > Tested-by: Frans Pop <elendil@planet.nl>
>>
>> Ok, now that I've looked at this, the urg_hole part of this change h=
as
>> to be removed.
>
> Thanks for taking a look... :-) The first patch btw was with RFC and
> without urg bits btw but you put that into some discarded like(?) sta=
te =20
> in patchwork... :-/

WRT the earlier patch, we have one more success report from one of the =
=20
users who reported the problem, namely Ian Zimmermann:

<http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D513695#155>

--=20
Matthias Andree
