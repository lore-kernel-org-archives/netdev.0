From: Doug Kehn <rdkehn@yahoo.com>
Subject: [PATCH] ksz884x: fix mtu for VLAN
Date: Wed, 11 Jan 2012 12:21:46 -0800 (PST)
Message-ID: <1326313306.57525.YahooMailNeo@web39305.mail.mud.yahoo.com>
Reply-To: Doug Kehn <rdkehn@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm3.bullet.mail.ac4.yahoo.com ([98.139.52.200]:43607 "HELO
	nm3.bullet.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757871Ab2AKU1t convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jan 2012 15:27:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Ethernet header does not account for the addition of a VLAN header.
=46ull size Ethernet frames containing VLAN header are not processed
because the frame is larger than the resulting hw mtu.

Signed-off-by: Doug Kehn <rdkehn@yahoo.com>
---
=A0drivers/net/ethernet/micrel/ksz884x.c |=A0=A0=A0 2 +-
=A01 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethern=
et/micrel/ksz884x.c
index 6ed09a8..e52cd31 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -746,7 +746,7 @@
=A0#define MAC_ADDR_ORDER(i)=A0=A0=A0 =A0=A0=A0 (ETH_ALEN - 1 - (i))
=A0
=A0#define MAX_ETHERNET_BODY_SIZE=A0=A0=A0 =A0=A0=A0 1500
-#define ETHERNET_HEADER_SIZE=A0=A0=A0 =A0=A0=A0 14
+#define ETHERNET_HEADER_SIZE=A0=A0=A0 =A0=A0=A0 (14 + VLAN_HLEN)
=A0
=A0#define MAX_ETHERNET_PACKET_SIZE=A0=A0=A0 \
=A0=A0=A0=A0 (MAX_ETHERNET_BODY_SIZE + ETHERNET_HEADER_SIZE)
--=20
1.7.4.1
