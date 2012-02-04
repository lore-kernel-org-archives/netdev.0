From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] tcp: RST: binding oif to iif for tcp v4
Date: Sat, 04 Feb 2012 09:06:56 +0100
Message-ID: <1328342816.2577.8.camel@edumazet-laptop>
References: <1328300212-18836-1-git-send-email-shawn.lu@ericsson.com>
	 <1328304719.2480.5.camel@edumazet-laptop>
	 <62162DF05402B341B3DB59932A1FA992B5B5C9FB94@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62597 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839Ab2BDIHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 03:07:01 -0500
Received: by wgbdt10 with SMTP id dt10so4588137wgb.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2012 00:06:59 -0800 (PST)
In-Reply-To: <62162DF05402B341B3DB59932A1FA992B5B5C9FB94@EUSAACMS0702.eamcs.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 16:43 -0500, Shawn Lu a =C3=A9c=
rit :

> [shawn Lu] ok.  Tcp socket is bind to device using SO_BINDTODEVICE  t=
o
> Limit traffic to specifc interface.  Sometime, it may not have a vali=
d
> Source address to get through ip_route_output_key.=20
>=20

Define "Sometime" ?

We have to force the oif only if requested by the socket in this case.

arg.bound_dev_if =3D sk ? sk->sk_bound_dev_if : 0;

Thats what we do in tcp_v4_send_ack() :
	if (oif)
		arg.bound_dev_if =3D oif;
