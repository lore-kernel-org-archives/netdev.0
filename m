From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 17/23] e1000e: cleanup - shift indentation left
	by exiting early in e1000_tso
Date: Sat, 21 Nov 2009 01:27:03 -0800
Message-ID: <20091121092702.5715.79005.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:51809 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751354AbZKUJ1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:27:13 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |  104 +++++++++++++++++++++----------------------
 1 files changed, 50 insertions(+), 54 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index a571676..25b0ef8 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3725,68 +3725,64 @@ static int e1000_tso(struct e1000_adapter *adapter,
 	u8 ipcss, ipcso, tucss, tucso, hdr_len;
 	int err;
 
-	if (skb_is_gso(skb)) {
-		if (skb_header_cloned(skb)) {
-			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-			if (err)
-				return err;
-		}
+	if (!skb_is_gso(skb))
+		return 0;
 
-		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
-		mss = skb_shinfo(skb)->gso_size;
-		if (skb->protocol == htons(ETH_P_IP)) {
-			struct iphdr *iph = ip_hdr(skb);
-			iph->tot_len = 0;
-			iph->check = 0;
-			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-								 iph->daddr, 0,
-								 IPPROTO_TCP,
-								 0);
-			cmd_length = E1000_TXD_CMD_IP;
-			ipcse = skb_transport_offset(skb) - 1;
-		} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
-			ipv6_hdr(skb)->payload_len = 0;
-			tcp_hdr(skb)->check =
-				~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-						 &ipv6_hdr(skb)->daddr,
-						 0, IPPROTO_TCP, 0);
-			ipcse = 0;
-		}
-		ipcss = skb_network_offset(skb);
-		ipcso = (void *)&(ip_hdr(skb)->check) - (void *)skb->data;
-		tucss = skb_transport_offset(skb);
-		tucso = (void *)&(tcp_hdr(skb)->check) - (void *)skb->data;
-		tucse = 0;
+	if (skb_header_cloned(skb)) {
+		err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+		if (err)
+			return err;
+	}
 
-		cmd_length |= (E1000_TXD_CMD_DEXT | E1000_TXD_CMD_TSE |
-			       E1000_TXD_CMD_TCP | (skb->len - (hdr_len)));
+	hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+	mss = skb_shinfo(skb)->gso_size;
+	if (skb->protocol == htons(ETH_P_IP)) {
+		struct iphdr *iph = ip_hdr(skb);
+		iph->tot_len = 0;
+		iph->check = 0;
+		tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
+		                                         0, IPPROTO_TCP, 0);
+		cmd_length = E1000_TXD_CMD_IP;
+		ipcse = skb_transport_offset(skb) - 1;
+	} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
+		ipv6_hdr(skb)->payload_len = 0;
+		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+		                                       &ipv6_hdr(skb)->daddr,
+		                                       0, IPPROTO_TCP, 0);
+		ipcse = 0;
+	}
+	ipcss = skb_network_offset(skb);
+	ipcso = (void *)&(ip_hdr(skb)->check) - (void *)skb->data;
+	tucss = skb_transport_offset(skb);
+	tucso = (void *)&(tcp_hdr(skb)->check) - (void *)skb->data;
+	tucse = 0;
 
-		i = tx_ring->next_to_use;
-		context_desc = E1000_CONTEXT_DESC(*tx_ring, i);
-		buffer_info = &tx_ring->buffer_info[i];
+	cmd_length |= (E1000_TXD_CMD_DEXT | E1000_TXD_CMD_TSE |
+	               E1000_TXD_CMD_TCP | (skb->len - (hdr_len)));
 
-		context_desc->lower_setup.ip_fields.ipcss  = ipcss;
-		context_desc->lower_setup.ip_fields.ipcso  = ipcso;
-		context_desc->lower_setup.ip_fields.ipcse  = cpu_to_le16(ipcse);
-		context_desc->upper_setup.tcp_fields.tucss = tucss;
-		context_desc->upper_setup.tcp_fields.tucso = tucso;
-		context_desc->upper_setup.tcp_fields.tucse = cpu_to_le16(tucse);
-		context_desc->tcp_seg_setup.fields.mss     = cpu_to_le16(mss);
-		context_desc->tcp_seg_setup.fields.hdr_len = hdr_len;
-		context_desc->cmd_and_length = cpu_to_le32(cmd_length);
+	i = tx_ring->next_to_use;
+	context_desc = E1000_CONTEXT_DESC(*tx_ring, i);
+	buffer_info = &tx_ring->buffer_info[i];
 
-		buffer_info->time_stamp = jiffies;
-		buffer_info->next_to_watch = i;
+	context_desc->lower_setup.ip_fields.ipcss  = ipcss;
+	context_desc->lower_setup.ip_fields.ipcso  = ipcso;
+	context_desc->lower_setup.ip_fields.ipcse  = cpu_to_le16(ipcse);
+	context_desc->upper_setup.tcp_fields.tucss = tucss;
+	context_desc->upper_setup.tcp_fields.tucso = tucso;
+	context_desc->upper_setup.tcp_fields.tucse = cpu_to_le16(tucse);
+	context_desc->tcp_seg_setup.fields.mss     = cpu_to_le16(mss);
+	context_desc->tcp_seg_setup.fields.hdr_len = hdr_len;
+	context_desc->cmd_and_length = cpu_to_le32(cmd_length);
 
-		i++;
-		if (i == tx_ring->count)
-			i = 0;
-		tx_ring->next_to_use = i;
+	buffer_info->time_stamp = jiffies;
+	buffer_info->next_to_watch = i;
 
-		return 1;
-	}
+	i++;
+	if (i == tx_ring->count)
+		i = 0;
+	tx_ring->next_to_use = i;
 
-	return 0;
+	return 1;
 }
 
 static bool e1000_tx_csum(struct e1000_adapter *adapter, struct sk_buff *skb)

