From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH v2 00/10] Low-level Ethernet debugging features.
Date: Fri, 10 Feb 2012 14:51:37 +0100
Message-ID: <1328881897.2443.20.camel@edumazet-laptop>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E6A@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>, jeffrey.t.kirsher@intel.com,
	Jeff Kirsher <tarbal@gmail.com>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:32929 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757901Ab2BJNvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 08:51:41 -0500
Received: by wgbgn7 with SMTP id gn7so465058wgb.1
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2012 05:51:40 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E6A@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 f=C3=A9vrier 2012 =C3=A0 13:45 +0000, David Laight a =C3=
=A9crit :
> > > I was thinking I might could get at least some NICs to generate R=
unt
> frames
> > > by sending small pkts and disabling frame padding, but haven't
> looked into
> > > it too hard yet.
> >=20
> > I am interested by this, do you know some NICs able to disable fram=
e
> > padding ?
>=20
> I'm reasonably sure some old NICs like the AMD lance will send runts.
> Quite likely any that require the drives to set the padded frame leng=
th.
>=20
> The same will be true when semi-generic HDLC controllers are used
> to send packets from DSPs, FPGAs and SOCs.
>=20

Apparently, drivers/net/ethernet/dlink/de620.c does this in its
de620_start_xmit() function :

	if ((len =3D skb->len) < RUNT)
		len =3D RUNT;

Thats interesting for two reasons :

1) We probably can remove the test to send runts if we want to test
things...

2) As is, we can leak kernel memory content to wire since we dont
initialize the padding data.
