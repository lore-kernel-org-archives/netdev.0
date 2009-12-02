From: <jie.yang@atheros.com>
Subject: [PATCH net-next]atl1e:disable NETIF_F_TSO6 for hardware limit
Date: Wed, 2 Dec 2009 11:18:34 +0800
Message-ID: <1259723914457-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ben@decadent.org.uk>, <558426@bugs.debian.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Jie Yang <jie.yang@atheros.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755215AbZLBDSb@vger.kernel.org>
Received: from mail.atheros.com ([10.10.20.108])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Tue, 01 Dec 2009 19:18:36 -0800
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jie Yang <jie.yang@atheros.com>

For hardware limit to support TSOV6, just disable this feature
Signed-off-by: Jie Yang <jie.yang@atheros.com>
---

 drivers/net/atl1e/atl1e_main.c |   36 ------------------------------------
 1 files changed, 0 insertions(+), 36 deletions(-)

diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index ad17e74..08f8c09 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1664,41 +1664,6 @@ static int atl1e_tso_csum(struct atl1e_adapter *adapter,
 			}
 			return 0;
 		}
-
-		if (offload_type & SKB_GSO_TCPV6) {
-			real_len = (((unsigned char *)ipv6_hdr(skb) - skb->data)
-					+ ntohs(ipv6_hdr(skb)->payload_len));
-			if (real_len < skb->len)
-				pskb_trim(skb, real_len);
-
-			/* check payload == 0 byte ? */
-			hdr_len = (skb_transport_offset(skb) + tcp_hdrlen(skb));
-			if (unlikely(skb->len == hdr_len)) {
-				/* only xsum need */
-				dev_warn(&pdev->dev,
-					"IPV6 tso with zero data??\n");
-				goto check_sum;
-			} else {
-				tcp_hdr(skb)->check = ~csum_ipv6_magic(
-						&ipv6_hdr(skb)->saddr,
-						&ipv6_hdr(skb)->daddr,
-						0, IPPROTO_TCP, 0);
-				tpd->word3 |= 1 << TPD_IP_VERSION_SHIFT;
-				hdr_len >>= 1;
-				tpd->word3 |= (hdr_len & TPD_V6_IPHLLO_MASK) <<
-					TPD_V6_IPHLLO_SHIFT;
-				tpd->word3 |= ((hdr_len >> 3) &
-					TPD_V6_IPHLHI_MASK) <<
-					TPD_V6_IPHLHI_SHIFT;
-				tpd->word3 |= (tcp_hdrlen(skb) >> 2 &
-					TPD_TCPHDRLEN_MASK) <<
-					TPD_TCPHDRLEN_SHIFT;
-				tpd->word3 |= ((skb_shinfo(skb)->gso_size) &
-					TPD_MSS_MASK) << TPD_MSS_SHIFT;
-					tpd->word3 |= 1 << TPD_SEGMENT_EN_SHIFT;
-			}
-		}
-		return 0;
 	}
 
 check_sum:
@@ -2287,7 +2252,6 @@ static int atl1e_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
 		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	netdev->features |= NETIF_F_LLTX;
 	netdev->features |= NETIF_F_TSO;
-	netdev->features |= NETIF_F_TSO6;
 
 	return 0;
 }
