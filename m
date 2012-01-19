From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: problem with noop and pfifo_fast Qdisc switching
Date: Thu, 19 Jan 2012 14:15:33 +0100
Message-ID: <1326978933.2249.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <81C3A93C17462B4BBD7E272753C105791FB3639775@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
To: Hemant-vilas RAMDASI <hemant.ramdasi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43832 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519Ab2ASNPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 08:15:37 -0500
In-Reply-To: <81C3A93C17462B4BBD7E272753C105791FB3639775@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 janvier 2012 =C3=A0 13:47 +0100, Hemant-vilas RAMDASI a =C3=
=A9crit :
> Hi,
>=20
> I have a situation where one of important message (phonet pipe messag=
e) gets dropped because of 'noop' Qdisc.
> This situation mostly happens when coming out of sleep and there is a=
 message to send.
> What I have observed is this.
> In normal case the qdisc used id pfifo_fast. When CPU goes to sleep, =
it changes the qdisc to noop.
> When CPU wakes up (because of a message from lower layers), phonet tr=
ies to send a control packet to driver and finds qdisc is still 'noop'.=
=20
> Because the concerned message is a control message, this packet drop =
is creating deadlock situation.
>=20
> How the switch between pfifo_fast and noop is handled? Is this someth=
ing solved in 3.0?
> We are running a older version of kernel (2.6.35 based).

If message is important, you should check return code from xmit
(NET_XMIT_CN is returned by noop_enqueue), and maybe resend it later.

Not sure by what you mean by 'cpu goes to sleep' or 'cpu wakes up' ?

Is it the machine going to suspend mode ?
