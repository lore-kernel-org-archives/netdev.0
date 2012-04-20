From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v3.4-rc 5/9] pch_gbe: improve coding style
Date: Fri, 20 Apr 2012 22:09:24 +0200
Message-ID: <d8c501a5825ad71606f326e91f3e8961225efabe.1334949388.git.richardcochran@gmail.com>
References: <cover.1334949388.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Takahiro Shimizu <tshimizu818@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:35319 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771Ab2DTUKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 16:10:13 -0400
Received: by wgbdr13 with SMTP id dr13so10012936wgb.1
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 13:10:12 -0700 (PDT)
In-Reply-To: <cover.1334949388.git.richardcochran@gmail.com>
In-Reply-To: <cover.1334949388.git.richardcochran@gmail.com>
References: <cover.1334949388.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Takahiro Shimizu <tshimizu818@gmail.com>

This patch clears up a few coding style issues:

- Makes two function definitions a bit nicer looking.
- Remove unneeded parentheses.
- Simplify macros for register bits.

[ RC - Rebased Takahiro's changes and wrote a commit message
  explaining the changes. ]

Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>
Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index dc15e93..799a85a 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -103,9 +103,9 @@ const char pch_driver_version[] = DRV_VERSION;
 /* Macros for ieee1588 */
 /* 0x40 Time Synchronization Channel Control Register Bits */
 #define MASTER_MODE   (1<<0)
-#define SLAVE_MODE    (0<<0)
+#define SLAVE_MODE    (0)
 #define V2_MODE       (1<<31)
-#define CAP_MODE0     (0<<16)
+#define CAP_MODE0     (0)
 #define CAP_MODE2     (1<<17)
 
 /* 0x44 Time Synchronization Channel Event Register Bits */
@@ -151,8 +151,8 @@ static int pch_ptp_match(struct sk_buff *skb, u16 uid_hi, u32 uid_lo, u16 seqid)
 		seqid  == *id);
 }
 
-static void pch_rx_timestamp(
-			struct pch_gbe_adapter *adapter, struct sk_buff *skb)
+static void
+pch_rx_timestamp(struct pch_gbe_adapter *adapter, struct sk_buff *skb)
 {
 	struct skb_shared_hwtstamps *shhwtstamps;
 	struct pci_dev *pdev;
@@ -189,8 +189,8 @@ out:
 	pch_ch_event_write(pdev, RX_SNAPSHOT_LOCKED);
 }
 
-static void pch_tx_timestamp(
-			struct pch_gbe_adapter *adapter, struct sk_buff *skb)
+static void
+pch_tx_timestamp(struct pch_gbe_adapter *adapter, struct sk_buff *skb)
 {
 	struct skb_shared_hwtstamps shhwtstamps;
 	struct pci_dev *pdev;
@@ -263,15 +263,15 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 		adapter->hwts_rx_en = 0;
-		pch_ch_control_write(pdev, (SLAVE_MODE | CAP_MODE0));
+		pch_ch_control_write(pdev, SLAVE_MODE | CAP_MODE0);
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
 		adapter->hwts_rx_en = 1;
-		pch_ch_control_write(pdev, (MASTER_MODE | CAP_MODE0));
+		pch_ch_control_write(pdev, MASTER_MODE | CAP_MODE0);
 		break;
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 		adapter->hwts_rx_en = 1;
-		pch_ch_control_write(pdev, (V2_MODE | CAP_MODE2));
+		pch_ch_control_write(pdev, V2_MODE | CAP_MODE2);
 		break;
 	default:
 		return -ERANGE;
-- 
1.7.2.5
