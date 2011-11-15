From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bonding xmit_policy
Date: Tue, 15 Nov 2011 08:12:15 +0100
Message-ID: <1321341135.8072.16.camel@edumazet-laptop>
References: <CANj2Ebfj+7R+wCK7jJennBN7_6THJGqs8FWSAPOv7BYYsR=u9w@mail.gmail.com>
	 <4EC0280A.3060100@gmail.com>
	 <CANj2EbfM+5+AFYkU+erMZBtf0cCXkoDGRrXLGQFHYVL_6qvWFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, netdev@vger.kernel.org
To: Simon Chen <simonchennj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38899 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092Ab1KOHMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 02:12:21 -0500
Received: by wwe5 with SMTP id 5so5611954wwe.1
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 23:12:20 -0800 (PST)
In-Reply-To: <CANj2EbfM+5+AFYkU+erMZBtf0cCXkoDGRrXLGQFHYVL_6qvWFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 novembre 2011 =C3=A0 01:20 -0500, Simon Chen a =C3=A9crit :
> Thanks, my bad.
>=20
> It is pretty strange that when I use 802.3ad mode, all my packets
> (from different TCP flows) egress the same NIC even though I choose
> xmit_policy to be layer3+4. That's why I wasn't quite sure whether th=
e
> policy is indeed in place.
>=20
> When I switch to balance-xor mode, the packets are roughly evenly
> distributed across two NICs.

AFAIK, layer4 information (soure/dst ports) is limited to ipv4 TCP/UDP
trafic.

Moreover, if your bond has 2 ports, only low order bit of source and ds=
t
port is used.

layer4_xor =3D ntohs((*layer4hdr ^ *(layer4hdr + 1)));

So if your trafic is RTP, it probably use only even ports, (RTCP using
odd ports), and uses a single slave.

=20
