From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH v3 net 6/6] net: mvneta: enable IP checksum with jumbo frames for Armada 38x on Port0
Date: Fri, 27 Nov 2015 16:44:26 +0100
Message-ID: <1448639066-13074-7-git-send-email-mw@semihalf.com>
References: <1448639066-13074-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, mw@semihalf.com,
	jaz@semihalf.com, tn@semihalf.com
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:33895 "EHLO
	mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754984AbbK0Pom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 10:44:42 -0500
Received: by lffu14 with SMTP id u14so133792708lff.1
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 07:44:41 -0800 (PST)
In-Reply-To: <1448639066-13074-1-git-send-email-mw@semihalf.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Ethernet controller found in the Armada 38x SoC's family support
TCP/IP checksumming with frame sizes larger than 1600 bytes, however
only on port 0.

This commit enables it by setting 'tx-csum-limit' to 9800B in
'ethernet@70000' node.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
---
 arch/arm/boot/dts/armada-38x.dtsi | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/boot/dts/armada-38x.dtsi b/arch/arm/boot/dts/armada-38x.dtsi
index c6a0e9d..e8b7f67 100644
--- a/arch/arm/boot/dts/armada-38x.dtsi
+++ b/arch/arm/boot/dts/armada-38x.dtsi
@@ -498,6 +498,7 @@
 				reg = <0x70000 0x4000>;
 				interrupts-extended = <&mpic 8>;
 				clocks = <&gateclk 4>;
+				tx-csum-limit = <9800>;
 				status = "disabled";
 			};
 
-- 
1.8.3.1
