From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 17:50:07 +0100
Message-ID: <1324486207.2301.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF21@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jun Zhao <mypopydev@gmail.com>, monstr@monstr.eu,
	David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:56616 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893Ab1LUQuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 11:50:12 -0500
Received: by vcbfk14 with SMTP id fk14so5891499vcb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 08:50:11 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF21@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 16:39 +0000, David Laight a =C3=
=A9crit :

> Many, many moons ago I wrote an ethernet driver that received into
> an array of 128 (mostly) 512byte buffers. Full sized frames would hav=
e
> multiple rx ring entries, but could almost always be copied into a
> correctly
> sized buffer with a single aligned copy (cache-line aligned if useful=
).
> This was significantly faster than other schemes - especially
> on systems where the iommu needed setting to allow the ethernet
> hardware to access memory.
>=20
> I don't know if the linux skb buffers would allow the ethernet
> driver to use (say) 1600 byte rx buffers, and link them together
> when a long frame arrives. Most ethernet HW I've seen will
> fragment long receives.
>=20
> The painful hardware is that which enforces a 4n byte alignment
> on the rx buffer! - on systens that can't do misaligned accesses.
> 2 bytes of junk would be fine!

It all depends on hardware capabilities.

Old hardware required a single area per frame. So driver had to talk to
the hardware the same way.

We now have hardware able to split data into several frags to reduce th=
e
overhead.

(Even using different pools to get a low number of frags, and good=20
filling ratio)

Take a look at NIU for example.
