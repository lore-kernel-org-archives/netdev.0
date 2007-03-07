From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [NET]: Use {htons,htonl,cpu_to_le16}() where appropriate.
Date: Wed, 07 Mar 2007 14:58:07 +0900 (JST)
Message-ID: <20070307.145807.117077720.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34385 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbXCGF5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 00:57:45 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Please consider pulling following changesets from the
"net-2.6.22-20070307a-byteorder-20070307" branch at
<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>.

Thank you.

HEADLINES
---------

    [NET] 802: Use hton{s,l}() where appropriate.
    [NET] 8021Q: Use htons() where appropriate.
    [NET] ATM: Use htons() where appropriate.
    [NET] BLUETOOTH: Use cpu_to_le16() where appropriate.
    [NET] CORE: Use htons() where appropriate.
    [NET] ETHERNET: Use htons() where appropriate.
    [NET] IEEE80211: Use htons() where appropriate.
    [NET] IPV4: Use hton{s,l}() where appropriate.
    [NET] NETFILTER: Use htonl() where appropriate.
    [NET] SCHED: Use htons() where appropriate.
    [NET] TIPC: Use htons() where appropriate.

DIFFSTAT
--------

 net/802/fddi.c                              |    4 ++--
 net/802/hippi.c                             |    4 ++--
 net/8021q/vlan_dev.c                        |    6 +++---
 net/atm/br2684.c                            |    4 ++--
 net/bluetooth/hci_conn.c                    |   18 +++++++++---------
 net/core/netpoll.c                          |    2 +-
 net/ethernet/eth.c                          |    2 +-
 net/ieee80211/ieee80211_tx.c                |    2 +-
 net/ipv4/ipvs/ip_vs_core.c                  |   10 +++++-----
 net/ipv4/ipvs/ip_vs_proto_ah.c              |   16 ++++++++--------
 net/ipv4/ipvs/ip_vs_xmit.c                  |   16 ++++++++--------
 net/ipv4/netfilter/ip_conntrack_proto_tcp.c |    9 ++++-----
 net/netfilter/nf_conntrack_proto_tcp.c      |    9 ++++-----
 net/sched/cls_rsvp.h                        |    2 +-
 net/sched/sch_api.c                         |    2 +-
 net/tipc/eth_media.c                        |    2 +-
 16 files changed, 53 insertions(+), 55 deletions(-)

CHANGESETS
----------

commit 2893c534ffba19c31c0321f8221eaf844306e951
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:18:33 2007 +0900

    [NET] 802: Use hton{s,l}() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/802/fddi.c b/net/802/fddi.c
index ace6386..8c86216 100644
--- a/net/802/fddi.c
+++ b/net/802/fddi.c
@@ -100,7 +100,7 @@ static int fddi_rebuild_header(struct sk_buff	*skb)
 	struct fddihdr *fddi = (struct fddihdr *)skb->data;
 
 #ifdef CONFIG_INET
-	if (fddi->hdr.llc_snap.ethertype == __constant_htons(ETH_P_IP))
+	if (fddi->hdr.llc_snap.ethertype == htons(ETH_P_IP))
 		/* Try to get ARP to resolve the header and fill destination address */
 		return arp_find(fddi->daddr, skb);
 	else
@@ -135,7 +135,7 @@ __be16 fddi_type_trans(struct sk_buff *skb, struct net_device *dev)
 	if(fddi->hdr.llc_8022_1.dsap==0xe0)
 	{
 		skb_pull(skb, FDDI_K_8022_HLEN-3);
-		type = __constant_htons(ETH_P_802_2);
+		type = htons(ETH_P_802_2);
 	}
 	else
 	{
diff --git a/net/802/hippi.c b/net/802/hippi.c
index 578f2a3..35dd938 100644
--- a/net/802/hippi.c
+++ b/net/802/hippi.c
@@ -60,7 +60,7 @@ static int hippi_header(struct sk_buff *skb, struct net_device *dev,
 	 * Due to the stupidity of the little endian byte-order we
 	 * have to set the fp field this way.
 	 */
-	hip->fp.fixed		= __constant_htonl(0x04800018);
+	hip->fp.fixed		= htonl(0x04800018);
 	hip->fp.d2_size		= htonl(len + 8);
 	hip->le.fc		= 0;
 	hip->le.double_wide	= 0;	/* only HIPPI 800 for the time being */
@@ -104,7 +104,7 @@ static int hippi_rebuild_header(struct sk_buff *skb)
 	 * Only IP is currently supported
 	 */
 
-	if(hip->snap.ethertype != __constant_htons(ETH_P_IP))
+	if(hip->snap.ethertype != htons(ETH_P_IP))
 	{
 		printk(KERN_DEBUG "%s: unable to resolve type %X addresses.\n",skb->dev->name,ntohs(hip->snap.ethertype));
 		return 0;

---
commit 60e71cd6525fdf2b35c71158bb5441a252e62a0e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:18:35 2007 +0900

    [NET] 8021Q: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 2fc8fe2..e961d59 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -258,7 +258,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	 * won't work for fault tolerant netware but does for the rest.
 	 */
 	if (*(unsigned short *)rawp == 0xFFFF) {
-		skb->protocol = __constant_htons(ETH_P_802_3);
+		skb->protocol = htons(ETH_P_802_3);
 		/* place it back on the queue to be handled by true layer 3 protocols.
 		 */
 
@@ -281,7 +281,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	/*
 	 *	Real 802.2 LLC
 	 */
-	skb->protocol = __constant_htons(ETH_P_802_2);
+	skb->protocol = htons(ETH_P_802_2);
 	/* place it back on the queue to be handled by upper layer protocols.
 	 */
 
@@ -445,7 +445,7 @@ int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * OTHER THINGS LIKE FDDI/TokenRing/802.3 SNAPs...
 	 */
 
-	if (veth->h_vlan_proto != __constant_htons(ETH_P_8021Q)) {
+	if (veth->h_vlan_proto != htons(ETH_P_8021Q)) {
 		int orig_headroom = skb_headroom(skb);
 		unsigned short veth_TCI;
 

---
commit c3f00ba0544698b83892b5a66f2f47937f7fd861
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:18:40 2007 +0900

    [NET] ATM: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index ec4ebd3..c444f5e 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -375,11 +375,11 @@ packet_fails_filter(__be16 type, struct br2684_vcc *brvcc, struct sk_buff *skb)
 {
 	if (brvcc->filter.netmask == 0)
 		return 0;			/* no filter in place */
-	if (type == __constant_htons(ETH_P_IP) &&
+	if (type == htons(ETH_P_IP) &&
 	    (((struct iphdr *) (skb->data))->daddr & brvcc->filter.
 	     netmask) == brvcc->filter.prefix)
 		return 0;
-	if (type == __constant_htons(ETH_P_ARP))
+	if (type == htons(ETH_P_ARP))
 		return 0;
 	/* TODO: we should probably filter ARPs too.. don't want to have
 	 *   them returning values that don't make sense, or is that ok?

---
commit 8770fa820e63c25efa4ed81c94f1dd3c0b9e4012
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:18:46 2007 +0900

    [NET] BLUETOOTH: Use cpu_to_le16() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index f3403fd..b3cb9b6 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -452,21 +452,21 @@ void hci_conn_enter_sniff_mode(struct hci_conn *conn)
 
 	if (lmp_sniffsubr_capable(hdev) && lmp_sniffsubr_capable(conn)) {
 		struct hci_cp_sniff_subrate cp;
-		cp.handle             = __cpu_to_le16(conn->handle);
-		cp.max_latency        = __constant_cpu_to_le16(0);
-		cp.min_remote_timeout = __constant_cpu_to_le16(0);
-		cp.min_local_timeout  = __constant_cpu_to_le16(0);
+		cp.handle             = cpu_to_le16(conn->handle);
+		cp.max_latency        = cpu_to_le16(0);
+		cp.min_remote_timeout = cpu_to_le16(0);
+		cp.min_local_timeout  = cpu_to_le16(0);
 		hci_send_cmd(hdev, OGF_LINK_POLICY,
 				OCF_SNIFF_SUBRATE, sizeof(cp), &cp);
 	}
 
 	if (!test_and_set_bit(HCI_CONN_MODE_CHANGE_PEND, &conn->pend)) {
 		struct hci_cp_sniff_mode cp;
-		cp.handle       = __cpu_to_le16(conn->handle);
-		cp.max_interval = __cpu_to_le16(hdev->sniff_max_interval);
-		cp.min_interval = __cpu_to_le16(hdev->sniff_min_interval);
-		cp.attempt      = __constant_cpu_to_le16(4);
-		cp.timeout      = __constant_cpu_to_le16(1);
+		cp.handle       = cpu_to_le16(conn->handle);
+		cp.max_interval = cpu_to_le16(hdev->sniff_max_interval);
+		cp.min_interval = cpu_to_le16(hdev->sniff_min_interval);
+		cp.attempt      = cpu_to_le16(4);
+		cp.timeout      = cpu_to_le16(1);
 		hci_send_cmd(hdev, OGF_LINK_POLICY,
 				OCF_SNIFF_MODE, sizeof(cp), &cp);
 	}

---
commit 5b7a496edad3eaab8ad5cdd92417f2ed313f534e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:18:52 2007 +0900

    [NET] CORE: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index da10194..4b22c4b 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -443,7 +443,7 @@ int __netpoll_rx(struct sk_buff *skb)
 		goto out;
 
 	/* check if netpoll clients need ARP */
-	if (skb->protocol == __constant_htons(ETH_P_ARP) &&
+	if (skb->protocol == htons(ETH_P_ARP) &&
 	    atomic_read(&trapped)) {
 		skb_queue_tail(&npi->arp_tx, skb);
 		return 1;

---
commit 2cf31ef94c0ded8a34a31df412135800ac9a144e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:19:03 2007 +0900

    [NET] ETHERNET: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 7391f55..41c5065 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -228,7 +228,7 @@ int eth_header_cache(struct neighbour *neigh, struct hh_cache *hh)
 	eth = (struct ethhdr *)
 	    (((u8 *) hh->hh_data) + (HH_DATA_OFF(sizeof(*eth))));
 
-	if (type == __constant_htons(ETH_P_802_3))
+	if (type == htons(ETH_P_802_3))
 		return -1;
 
 	eth->h_proto = type;

---
commit 383bf0f5ab9e4f34c61c16a2d2026251553a09ac
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:19:05 2007 +0900

    [NET] IEEE80211: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
index 0292d63..3fca434 100644
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -225,7 +225,7 @@ static int ieee80211_classify(struct sk_buff *skb)
 	struct iphdr *ip;
 
 	eth = (struct ethhdr *)skb->data;
-	if (eth->h_proto != __constant_htons(ETH_P_IP))
+	if (eth->h_proto != htons(ETH_P_IP))
 		return 0;
 
 	ip = skb->nh.iph;

---
commit b6f37ee32bf6fa670330e35e642f03960eb76251
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:19:10 2007 +0900

    [NET] IPV4: Use hton{s,l}() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 24d7b66..858686d 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -617,7 +617,7 @@ static int ip_vs_out_icmp(struct sk_buff **pskb, int *related)
 	*related = 1;
 
 	/* reassemble IP fragments */
-	if (skb->nh.iph->frag_off & __constant_htons(IP_MF|IP_OFFSET)) {
+	if (skb->nh.iph->frag_off & htons(IP_MF|IP_OFFSET)) {
 		skb = ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT);
 		if (!skb)
 			return NF_STOLEN;
@@ -659,7 +659,7 @@ static int ip_vs_out_icmp(struct sk_buff **pskb, int *related)
 		return NF_ACCEPT;
 
 	/* Is the embedded protocol header present? */
-	if (unlikely(cih->frag_off & __constant_htons(IP_OFFSET) &&
+	if (unlikely(cih->frag_off & htons(IP_OFFSET) &&
 		     pp->dont_defrag))
 		return NF_ACCEPT;
 
@@ -755,7 +755,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff **pskb,
 		return NF_ACCEPT;
 
 	/* reassemble IP fragments */
-	if (unlikely(iph->frag_off & __constant_htons(IP_MF|IP_OFFSET) &&
+	if (unlikely(iph->frag_off & htons(IP_MF|IP_OFFSET) &&
 		     !pp->dont_defrag)) {
 		skb = ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT);
 		if (!skb)
@@ -861,7 +861,7 @@ ip_vs_in_icmp(struct sk_buff **pskb, int *related, unsigned int hooknum)
 	*related = 1;
 
 	/* reassemble IP fragments */
-	if (skb->nh.iph->frag_off & __constant_htons(IP_MF|IP_OFFSET)) {
+	if (skb->nh.iph->frag_off & htons(IP_MF|IP_OFFSET)) {
 		skb = ip_vs_gather_frags(skb,
 					 hooknum == NF_IP_LOCAL_IN ?
 					 IP_DEFRAG_VS_IN : IP_DEFRAG_VS_FWD);
@@ -905,7 +905,7 @@ ip_vs_in_icmp(struct sk_buff **pskb, int *related, unsigned int hooknum)
 		return NF_ACCEPT;
 
 	/* Is the embedded protocol header present? */
-	if (unlikely(cih->frag_off & __constant_htons(IP_OFFSET) &&
+	if (unlikely(cih->frag_off & htons(IP_OFFSET) &&
 		     pp->dont_defrag))
 		return NF_ACCEPT;
 
diff --git a/net/ipv4/ipvs/ip_vs_proto_ah.c b/net/ipv4/ipvs/ip_vs_proto_ah.c
index 8b0505b..a842676 100644
--- a/net/ipv4/ipvs/ip_vs_proto_ah.c
+++ b/net/ipv4/ipvs/ip_vs_proto_ah.c
@@ -52,15 +52,15 @@ ah_conn_in_get(const struct sk_buff *skb,
 	if (likely(!inverse)) {
 		cp = ip_vs_conn_in_get(IPPROTO_UDP,
 				       iph->saddr,
-				       __constant_htons(PORT_ISAKMP),
+				       htons(PORT_ISAKMP),
 				       iph->daddr,
-				       __constant_htons(PORT_ISAKMP));
+				       htons(PORT_ISAKMP));
 	} else {
 		cp = ip_vs_conn_in_get(IPPROTO_UDP,
 				       iph->daddr,
-				       __constant_htons(PORT_ISAKMP),
+				       htons(PORT_ISAKMP),
 				       iph->saddr,
-				       __constant_htons(PORT_ISAKMP));
+				       htons(PORT_ISAKMP));
 	}
 
 	if (!cp) {
@@ -89,15 +89,15 @@ ah_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 	if (likely(!inverse)) {
 		cp = ip_vs_conn_out_get(IPPROTO_UDP,
 					iph->saddr,
-					__constant_htons(PORT_ISAKMP),
+					htons(PORT_ISAKMP),
 					iph->daddr,
-					__constant_htons(PORT_ISAKMP));
+					htons(PORT_ISAKMP));
 	} else {
 		cp = ip_vs_conn_out_get(IPPROTO_UDP,
 					iph->daddr,
-					__constant_htons(PORT_ISAKMP),
+					htons(PORT_ISAKMP),
 					iph->saddr,
-					__constant_htons(PORT_ISAKMP));
+					htons(PORT_ISAKMP));
 	}
 
 	if (!cp) {
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index e1f77bd..f73c5ac 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -178,7 +178,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if ((skb->len > mtu) && (iph->frag_off&__constant_htons(IP_DF))) {
+	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL("ip_vs_bypass_xmit(): frag needed\n");
@@ -245,7 +245,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if ((skb->len > mtu) && (iph->frag_off&__constant_htons(IP_DF))) {
+	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL_PKT(0, pp, skb, 0, "ip_vs_nat_xmit(): frag needed for");
@@ -329,10 +329,10 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	if (skb->protocol != __constant_htons(ETH_P_IP)) {
+	if (skb->protocol != htons(ETH_P_IP)) {
 		IP_VS_DBG_RL("ip_vs_tunnel_xmit(): protocol error, "
 			     "ETH_P_IP: %d, skb protocol: %d\n",
-			     __constant_htons(ETH_P_IP), skb->protocol);
+			     htons(ETH_P_IP), skb->protocol);
 		goto tx_error;
 	}
 
@@ -350,9 +350,9 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (skb->dst)
 		skb->dst->ops->update_pmtu(skb->dst, mtu);
 
-	df |= (old_iph->frag_off&__constant_htons(IP_DF));
+	df |= (old_iph->frag_off & htons(IP_DF));
 
-	if ((old_iph->frag_off&__constant_htons(IP_DF))
+	if ((old_iph->frag_off & htons(IP_DF))
 	    && mtu < ntohs(old_iph->tot_len)) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		ip_rt_put(rt);
@@ -445,7 +445,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if ((iph->frag_off&__constant_htons(IP_DF)) && skb->len > mtu) {
+	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		ip_rt_put(rt);
 		IP_VS_DBG_RL("ip_vs_dr_xmit(): frag needed\n");
@@ -519,7 +519,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if ((skb->len > mtu) && (skb->nh.iph->frag_off&__constant_htons(IP_DF))) {
+	if ((skb->len > mtu) && (skb->nh.iph->frag_off & htons(IP_DF))) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL("ip_vs_in_icmp(): frag needed\n");
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
index 170d625..88499df 100644
--- a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
@@ -515,11 +515,10 @@ static void tcp_sack(const struct sk_buff *skb,
 
 	/* Fast path for timestamp-only option */
 	if (length == TCPOLEN_TSTAMP_ALIGNED*4
-	    && *(__be32 *)ptr ==
-		__constant_htonl((TCPOPT_NOP << 24)
-				 | (TCPOPT_NOP << 16)
-				 | (TCPOPT_TIMESTAMP << 8)
-				 | TCPOLEN_TIMESTAMP))
+	    && *(__be32 *)ptr == htonl((TCPOPT_NOP << 24)
+				       | (TCPOPT_NOP << 16)
+				       | (TCPOPT_TIMESTAMP << 8)
+				       | TCPOLEN_TIMESTAMP))
 		return;
 
 	while (length > 0) {

---
commit efc9c3e5d195de1b13d52b370c370ecd74587a3a
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:21:00 2007 +0900

    [NET] NETFILTER: Use htonl() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 069b85c..f132f75 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -470,11 +470,10 @@ static void tcp_sack(const struct sk_buff *skb, unsigned int dataoff,
 
 	/* Fast path for timestamp-only option */
 	if (length == TCPOLEN_TSTAMP_ALIGNED*4
-	    && *(__be32 *)ptr ==
-		__constant_htonl((TCPOPT_NOP << 24)
-				 | (TCPOPT_NOP << 16)
-				 | (TCPOPT_TIMESTAMP << 8)
-				 | TCPOLEN_TIMESTAMP))
+	    && *(__be32 *)ptr == htonl((TCPOPT_NOP << 24)
+				       | (TCPOPT_NOP << 16)
+				       | (TCPOPT_TIMESTAMP << 8)
+				       | TCPOLEN_TIMESTAMP))
 		return;
 
 	while (length > 0) {

---
commit 6cc0f74b64a80bc14627112e31cc594e818abb68
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:21:20 2007 +0900

    [NET] SCHED: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 7853621..b6ac0e2 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -160,7 +160,7 @@ restart:
 	dst = &nhptr->daddr;
 	protocol = nhptr->protocol;
 	xprt = ((u8*)nhptr) + (nhptr->ihl<<2);
-	if (nhptr->frag_off&__constant_htons(IP_MF|IP_OFFSET))
+	if (nhptr->frag_off & htons(IP_MF|IP_OFFSET))
 		return -1;
 #endif
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ecc988a..4a927a5 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1146,7 +1146,7 @@ reclassify:
 
 	for ( ; tp; tp = tp->next) {
 		if ((tp->protocol == protocol ||
-			tp->protocol == __constant_htons(ETH_P_ALL)) &&
+			tp->protocol == htons(ETH_P_ALL)) &&
 			(err = tp->classify(skb, tp, res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 			if ( TC_ACT_RECLASSIFY == err) {

---
commit 1e243778d99257c143bd104d0e17b3125d602cce
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:21:31 2007 +0900

    [NET] TIPC: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 9be4839..f71ba9d 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -140,7 +140,7 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 		return -EDQUOT;
 	if (!eb_ptr->dev) {
 		eb_ptr->dev = dev;
-		eb_ptr->tipc_packet_type.type = __constant_htons(ETH_P_TIPC);
+		eb_ptr->tipc_packet_type.type = htons(ETH_P_TIPC);
 		eb_ptr->tipc_packet_type.dev = dev;
 		eb_ptr->tipc_packet_type.func = recv_msg;
 		eb_ptr->tipc_packet_type.af_packet_priv = eb_ptr;

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
