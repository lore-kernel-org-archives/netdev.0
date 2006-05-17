From: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Subject: Re: [PATCH 3/6] new pcmcia IDs for hostap
Date: Wed, 17 May 2006 10:36:03 +0200
Message-ID: <200605171036.05164.linux-arm@hrw.one.pl>
References: <200605161621.22459.linux-arm@hrw.one.pl> <200605161724.53495.linux-arm@hrw.one.pl> <1147814144.14914.38.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>, Jouni Malinen <jkmaline@cc.hut.fi>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v813.rev.tld.pl ([195.149.226.213]:53141 "EHLO
	smtp.host4.kei.pl") by vger.kernel.org with ESMTP id S932487AbWEQIgP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 04:36:15 -0400
To: Pavel Roskin <proski@gnu.org>, netdev@vger.kernel.org
In-Reply-To: <1147814144.14914.38.camel@dv>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dnia wtorek, 16 maja 2006 23:15, Pavel Roskin napisa=B3:
> On Tue, 2006-05-16 at 17:24 +0200, Marcin Juszkiewicz wrote:

> >   product info: "D-Link", "DCF-660W", "", ""
> >   manfid: 0xd601, 0x0005

> This manfid is in the driver already,

dropped then

> >   product info: "NETGEAR", "MA701 Wireless CF Card", ""
> >   manfid: 0xd601, 0x0002

> This manfid is in the driver too.

dropped

> >   product info:"PLANEX COMMUNICATION INC", "PLANEX GW-CF11X Wireles=
s CF Card", "", ""
> >   manfid: 0xd601, 0x0010=20

> This manfid is in the driver.

dropped

> >   product info: "U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 0=
1.02", ""
> >   manfid: 0x0156, 0x0002=20

> Yes, that's needed.  I was thinking maybe we could have a macro to ma=
tch
> manfid and the third string.  0x0156, 0x0002 and "Version 01.02" only
> appear for Prism based cards.

> > +	PCMCIA_DEVICE_PROD_ID1234("ASUS", "802_11B_CF_CARD_25", "Version =
01.00", "",
> > +		0x78fc06ee, 0x45a50c1e, 0xa57adb8c, 0x00000000),=20

> I think it would be better to omit the empty string.  It's mostly a
> matter of taste, but if there are cards with the same ID except the
> fourth string, they would be almost definitely compatible.
>
> This entry shouldn't be needed because the manfid 0x02aa, 0x0002 is
> already in the driver.

dropped

> > +	PCMCIA_DEVICE_PROD_ID123(
> > +		"Pretec", "CompactWLAN Card 802.11b", "2.5",
> > +		0x1cadd3e5, 0xe697636c, 0x7a5bfcf1),
>
> That's a good one.

That one I sent to You, lkml over month ago but you had it already in=20
24-hostap_cs_id.diff patch (which you told later to ignore).

> > +	PCMCIA_DEVICE_PROD_ID1234(
> > +		"U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02", ""
> > +		0xc7b8df9d, 0x1700d087, 0x4b74baa0, 0x00000000),
>
> Another useful entry, but please don't match the empty string.

updated:

Platform: Sharp Zaurus C760 running 2.6.16 and pcmciautils 013.

root@c7x0:~# pccardctl ident
Socket 0:
  product info: "Pretec", "CompactWLAN Card 802.11b", "2.5"
  manfid: 0x0156, 0x0002
  function: 6 (network)

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
=46rom: Jochen Friedrich=20

Yet another card known to work OK with hostap_cs:

# pccardctl ident
Socket 0:
  no product info available
Socket 1:
  product info: "U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02=
", ""
  manfid: 0x0156, 0x0002
  function: 6 (network)

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D

Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

 drivers/net/wireless/hostap/hostap_cs.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux/drivers/net/wireless/hostap/hostap_cs.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-17 10:23=
:00.000000000 +0200
+++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-17 10:25:45.0=
00000000 +0200
@@ -923,6 +923,12 @@
 	PCMCIA_DEVICE_PROD_ID12(
 		"ZoomAir 11Mbps High", "Rate wireless Networking",
 		0x273fe3db, 0x32a1eaee),
+	PCMCIA_DEVICE_PROD_ID123(
+		"Pretec", "CompactWLAN Card 802.11b", "2.5",
+		0x1cadd3e5, 0xe697636c, 0x7a5bfcf1),
+	PCMCIA_DEVICE_PROD_ID123(
+		"U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02",
+		0xc7b8df9d, 0x1700d087, 0x4b74baa0),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);


--=20
JID: hrw-jabber.org
Sharp Zaurus C-760 (OZ 3.5.x)
OpenEmbedded/OpenZaurus/OPIE developer

   Fear leads to anger, anger leads to hate, hate... leads to suffering=
=2E
   		-- Yoda
