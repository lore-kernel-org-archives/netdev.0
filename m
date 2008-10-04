From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: [PATCH 1/2] r8169: WoL fixes
Date: Sat, 4 Oct 2008 18:07:35 +0200
Message-ID: <20081004180735.2dc9a386@neptune.home>
References: <20081004180521.7aa7e232@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Len Brown <lenb@kernel.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppp-111-39.adsl.restena.lu ([158.64.111.39]:54419 "EHLO
	bonbons.gotdns.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751460AbYJDQPE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 12:15:04 -0400
In-Reply-To: <20081004180521.7aa7e232@neptune.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When probing the chip and handling it's power management settings
also remember wether WoL feature is enabled.

Without this patch one has to call ethtool to change WoL settings
for this flag to be set and any WoL being enabled on suspend to
RAM.

Signed-off-by: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
---
--- linux-2.6.27-rc8-git6.orig/drivers/net/r8169.c	2008-10-04 16:37:36.=
000000000 +0200
+++ linux-2.6.27-rc8-git6/drivers/net/r8169.c	2008-10-04 12:31:48.00000=
0000 +0200
@@ -1706,6 +1706,10 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
 	RTL_W8(Config5, RTL_R8(Config5) & PMEStatus);
+	if ((RTL_R8(Config3) & (LinkUp | MagicPacket)) !=3D 0)
+		tp->features |=3D RTL_FEATURE_WOL;
+	if ((RTL_R8(Config5) & (UWF | BWF | MWF)) !=3D 0)
+		tp->features |=3D RTL_FEATURE_WOL;
 	tp->features |=3D rtl_try_msi(pdev, ioaddr, cfg);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
=20
