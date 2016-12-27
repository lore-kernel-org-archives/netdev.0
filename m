From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 09/11] net: mvpp2: simplify MVPP2_PRS_RI_* definitions
Date: Tue, 27 Dec 2016 17:54:18 +0100
Message-ID: <1482857660-16092-10-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482857660-16092-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36666 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933053AbcL0Qyd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 11:54:33 -0500
In-Reply-To: <1482857660-16092-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the MVPP2_PRS_RI_* definitions use the ~(value) syntax, which
doesn't compile nicely on 64-bit. Moreover, those definitions are in
fact unneeded, since they are always used in combination with a bit
mask that ensures only the appropriate bits are modified.

Therefore, such definitions should just be set to 0x0. For example:

 #define MVPP2_PRS_RI_L2_CAST_MASK              0x600
 #define MVPP2_PRS_RI_L2_UCAST                  ~(BIT(9) | BIT(10))
 #define MVPP2_PRS_RI_L2_MCAST                  BIT(9)
 #define MVPP2_PRS_RI_L2_BCAST                  BIT(10)

becomes

 #define MVPP2_PRS_RI_L2_CAST_MASK              0x600
 #define MVPP2_PRS_RI_L2_UCAST                  0x0
 #define MVPP2_PRS_RI_L2_MCAST                  BIT(9)
 #define MVPP2_PRS_RI_L2_BCAST                  BIT(10)

Because the values (MVPP2_PRS_RI_L2_UCAST, MVPP2_PRS_RI_L2_MCAST and
MVPP2_PRS_RI_L2_BCAST) are always applied with
MVPP2_PRS_RI_L2_CAST_MASK, and therefore there is no need for
MVPP2_PRS_RI_L2_UCAST to be defined as ~(BIT(9) | BIT(10)).

It fixes the following warnings when building the driver on a 64-bit
platform (which is not possible as of this commit, but will be enabled
in a follow-up commit):

drivers/net/ethernet/marvell/mvpp2.c: In function ‘mvpp2_prs_mac_promisc_set’:
drivers/net/ethernet/marvell/mvpp2.c:524:33: warning: large integer implicitly truncated to unsigned type [-Woverflow]
 #define MVPP2_PRS_RI_L2_UCAST   ~(BIT(9) | BIT(10))
                                 ^
drivers/net/ethernet/marvell/mvpp2.c:1459:33: note: in expansion of macro ‘MVPP2_PRS_RI_L2_UCAST’
   mvpp2_prs_sram_ri_update(&pe, MVPP2_PRS_RI_L2_UCAST,

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 36c73dc..58cf9af 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -511,19 +511,19 @@ enum mvpp2_tag_type {
 #define MVPP2_PRS_RI_MAC_ME_MASK		0x1
 #define MVPP2_PRS_RI_DSA_MASK			0x2
 #define MVPP2_PRS_RI_VLAN_MASK			0xc
-#define MVPP2_PRS_RI_VLAN_NONE			~(BIT(2) | BIT(3))
+#define MVPP2_PRS_RI_VLAN_NONE			0x0
 #define MVPP2_PRS_RI_VLAN_SINGLE		BIT(2)
 #define MVPP2_PRS_RI_VLAN_DOUBLE		BIT(3)
 #define MVPP2_PRS_RI_VLAN_TRIPLE		(BIT(2) | BIT(3))
 #define MVPP2_PRS_RI_CPU_CODE_MASK		0x70
 #define MVPP2_PRS_RI_CPU_CODE_RX_SPEC		BIT(4)
 #define MVPP2_PRS_RI_L2_CAST_MASK		0x600
-#define MVPP2_PRS_RI_L2_UCAST			~(BIT(9) | BIT(10))
+#define MVPP2_PRS_RI_L2_UCAST			0x0
 #define MVPP2_PRS_RI_L2_MCAST			BIT(9)
 #define MVPP2_PRS_RI_L2_BCAST			BIT(10)
 #define MVPP2_PRS_RI_PPPOE_MASK			0x800
 #define MVPP2_PRS_RI_L3_PROTO_MASK		0x7000
-#define MVPP2_PRS_RI_L3_UN			~(BIT(12) | BIT(13) | BIT(14))
+#define MVPP2_PRS_RI_L3_UN			0x0
 #define MVPP2_PRS_RI_L3_IP4			BIT(12)
 #define MVPP2_PRS_RI_L3_IP4_OPT			BIT(13)
 #define MVPP2_PRS_RI_L3_IP4_OTHER		(BIT(12) | BIT(13))
@@ -531,7 +531,7 @@ enum mvpp2_tag_type {
 #define MVPP2_PRS_RI_L3_IP6_EXT			(BIT(12) | BIT(14))
 #define MVPP2_PRS_RI_L3_ARP			(BIT(13) | BIT(14))
 #define MVPP2_PRS_RI_L3_ADDR_MASK		0x18000
-#define MVPP2_PRS_RI_L3_UCAST			~(BIT(15) | BIT(16))
+#define MVPP2_PRS_RI_L3_UCAST			0x0
 #define MVPP2_PRS_RI_L3_MCAST			BIT(15)
 #define MVPP2_PRS_RI_L3_BCAST			(BIT(15) | BIT(16))
 #define MVPP2_PRS_RI_IP_FRAG_MASK		0x20000
-- 
2.7.4
