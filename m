From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH] sbc8641: drop bogus PHY IRQ entries from DTS file
Date: Tue, 8 Dec 2015 17:44:02 -0500
Message-ID: <1449614642-8161-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42631 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbbLHWpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 17:45:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This file was originally cloned off of the MPC8641D-HPCN reference
platform, which actually had a PHY IRQ line connected.  However
this board does not.  The bogus entry was largely inert and went
undetected until commit 321beec5047af83db90c88114b7e664b156f49fe
("net: phy: Use interrupts when available in NOLINK state") was
added to the tree.

With the above commit, the board fails to NFS boot since it sits
waiting for a PHY IRQ event that of course never arrives.  Removing
the bogus entries from the DTS file fixes the issue.

Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 arch/powerpc/boot/dts/sbc8641d.dts | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/arch/powerpc/boot/dts/sbc8641d.dts b/arch/powerpc/boot/dts/sbc8641d.dts
index 631ede72e226..68f0ed7626bd 100644
--- a/arch/powerpc/boot/dts/sbc8641d.dts
+++ b/arch/powerpc/boot/dts/sbc8641d.dts
@@ -227,23 +227,15 @@
 				reg = <0x520 0x20>;
 
 				phy0: ethernet-phy@1f {
-					interrupt-parent = <&mpic>;
-					interrupts = <10 1>;
 					reg = <0x1f>;
 				};
 				phy1: ethernet-phy@0 {
-					interrupt-parent = <&mpic>;
-					interrupts = <10 1>;
 					reg = <0>;
 				};
 				phy2: ethernet-phy@1 {
-					interrupt-parent = <&mpic>;
-					interrupts = <10 1>;
 					reg = <1>;
 				};
 				phy3: ethernet-phy@2 {
-					interrupt-parent = <&mpic>;
-					interrupts = <10 1>;
 					reg = <2>;
 				};
 				tbi0: tbi-phy@11 {
-- 
2.6.1
