From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] eth: indentation and cleanup (revised)
Date: Tue, 15 Aug 2006 14:05:52 -0700
Message-ID: <20060815140552.577a9117@dxpl.pdx.osdl.net>
References: <20060815125759.590a4a44@dxpl.pdx.osdl.net>
	<20060815130245.5e11807b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Randy.Dunlap" <rdunlap@xenotime.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:35483 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750713AbWHOVGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 17:06:02 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060815130245.5e11807b@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Run ethernet support through Lindent and fix up.
Applies after docbook comments patch
 
Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- net-2.6.19.orig/net/ethernet/eth.c
+++ net-2.6.19/net/ethernet/eth.c
@@ -78,39 +78,37 @@ __setup("ether=", netdev_boot_setup);
  * in here instead. It is up to the 802.2 layer to carry protocol information.
  */
 int eth_header(struct sk_buff *skb, struct net_device *dev, unsigned short type,
-	   void *daddr, void *saddr, unsigned len)
+	       void *daddr, void *saddr, unsigned len)
 {
-	struct ethhdr *eth = (struct ethhdr *)skb_push(skb,ETH_HLEN);
+	struct ethhdr *eth = (struct ethhdr *)skb_push(skb, ETH_HLEN);
 
-	if(type!=ETH_P_802_3) 
+	if (type != ETH_P_802_3)
 		eth->h_proto = htons(type);
 	else
 		eth->h_proto = htons(len);
 
 	/*
-	 *	Set the source hardware address. 
+	 *      Set the source hardware address.
 	 */
-	 
-	if(!saddr)
+
+	if (!saddr)
 		saddr = dev->dev_addr;
-	memcpy(eth->h_source,saddr,dev->addr_len);
+	memcpy(eth->h_source, saddr, dev->addr_len);
 
-	if(daddr)
-	{
-		memcpy(eth->h_dest,daddr,dev->addr_len);
+	if (daddr) {
+		memcpy(eth->h_dest, daddr, dev->addr_len);
 		return ETH_HLEN;
 	}
-	
+
 	/*
-	 *	Anyway, the loopback-device should never use this function... 
+	 *      Anyway, the loopback-device should never use this function...
 	 */
 
-	if (dev->flags & (IFF_LOOPBACK|IFF_NOARP)) 
-	{
+	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP)) {
 		memset(eth->h_dest, 0, dev->addr_len);
 		return ETH_HLEN;
 	}
-	
+
 	return -ETH_HLEN;
 }
 
@@ -129,17 +127,16 @@ int eth_rebuild_header(struct sk_buff *s
 	struct ethhdr *eth = (struct ethhdr *)skb->data;
 	struct net_device *dev = skb->dev;
 
-	switch (eth->h_proto)
-	{
+	switch (eth->h_proto) {
 #ifdef CONFIG_INET
 	case __constant_htons(ETH_P_IP):
- 		return arp_find(eth->h_dest, skb);
-#endif	
+		return arp_find(eth->h_dest, skb);
+#endif
 	default:
 		printk(KERN_DEBUG
-		       "%s: unable to resolve type %X addresses.\n", 
+		       "%s: unable to resolve type %X addresses.\n",
 		       dev->name, (int)eth->h_proto);
-		
+
 		memcpy(eth->h_source, dev->dev_addr, dev->addr_len);
 		break;
 	}
@@ -147,7 +144,6 @@ int eth_rebuild_header(struct sk_buff *s
 	return 0;
 }
 
-
 /**
  * eth_type_trans - determine the packet's protocol ID.
  * @skb: received socket data
@@ -161,50 +157,51 @@ __be16 eth_type_trans(struct sk_buff *sk
 {
 	struct ethhdr *eth;
 	unsigned char *rawp;
-	
+
 	skb->mac.raw = skb->data;
-	skb_pull(skb,ETH_HLEN);
+	skb_pull(skb, ETH_HLEN);
 	eth = eth_hdr(skb);
-	
+
 	if (is_multicast_ether_addr(eth->h_dest)) {
 		if (!compare_ether_addr(eth->h_dest, dev->broadcast))
 			skb->pkt_type = PACKET_BROADCAST;
 		else
 			skb->pkt_type = PACKET_MULTICAST;
 	}
-	
+
 	/*
-	 *	This ALLMULTI check should be redundant by 1.4
-	 *	so don't forget to remove it.
+	 *      This ALLMULTI check should be redundant by 1.4
+	 *      so don't forget to remove it.
 	 *
-	 *	Seems, you forgot to remove it. All silly devices
-	 *	seems to set IFF_PROMISC.
+	 *      Seems, you forgot to remove it. All silly devices
+	 *      seems to set IFF_PROMISC.
 	 */
-	 
-	else if(1 /*dev->flags&IFF_PROMISC*/) {
+
+	else if (1 /*dev->flags&IFF_PROMISC */ ) {
 		if (unlikely(compare_ether_addr(eth->h_dest, dev->dev_addr)))
 			skb->pkt_type = PACKET_OTHERHOST;
 	}
-	
+
 	if (ntohs(eth->h_proto) >= 1536)
 		return eth->h_proto;
-		
+
 	rawp = skb->data;
-	
+
 	/*
-	 *	This is a magic hack to spot IPX packets. Older Novell breaks
-	 *	the protocol design and runs IPX over 802.3 without an 802.2 LLC
-	 *	layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
-	 *	won't work for fault tolerant netware but does for the rest.
+	 *      This is a magic hack to spot IPX packets. Older Novell breaks
+	 *      the protocol design and runs IPX over 802.3 without an 802.2 LLC
+	 *      layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
+	 *      won't work for fault tolerant netware but does for the rest.
 	 */
 	if (*(unsigned short *)rawp == 0xFFFF)
 		return htons(ETH_P_802_3);
-		
+
 	/*
-	 *	Real 802.2 LLC
+	 *      Real 802.2 LLC
 	 */
 	return htons(ETH_P_802_2);
 }
+EXPORT_SYMBOL(eth_type_trans);
 
 /**
  * eth_header_parse - extract hardware address from packet
@@ -230,8 +227,8 @@ int eth_header_cache(struct neighbour *n
 	struct ethhdr *eth;
 	struct net_device *dev = neigh->dev;
 
-	eth = (struct ethhdr*)
-		(((u8*)hh->hh_data) + (HH_DATA_OFF(sizeof(*eth))));
+	eth = (struct ethhdr *)
+	    (((u8 *) hh->hh_data) + (HH_DATA_OFF(sizeof(*eth))));
 
 	if (type == __constant_htons(ETH_P_802_3))
 		return -1;
@@ -251,14 +248,13 @@ int eth_header_cache(struct neighbour *n
  *
  * Called by Address Resolution module to notify changes in address.
  */
-void eth_header_cache_update(struct hh_cache *hh, struct net_device *dev, unsigned char * haddr)
+void eth_header_cache_update(struct hh_cache *hh, struct net_device *dev,
+			     unsigned char *haddr)
 {
-	memcpy(((u8*)hh->hh_data) + HH_DATA_OFF(sizeof(struct ethhdr)),
+	memcpy(((u8 *) hh->hh_data) + HH_DATA_OFF(sizeof(struct ethhdr)),
 	       haddr, dev->addr_len);
 }
 
-EXPORT_SYMBOL(eth_type_trans);
-
 /**
  * eth_mac_addr - set new Ethernet hardware address
  * @dev: network device
@@ -270,10 +266,10 @@ EXPORT_SYMBOL(eth_type_trans);
  */
 static int eth_mac_addr(struct net_device *dev, void *p)
 {
-	struct sockaddr *addr=p;
+	struct sockaddr *addr = p;
 	if (netif_running(dev))
 		return -EBUSY;
-	memcpy(dev->dev_addr, addr->sa_data,dev->addr_len);
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	return 0;
 }
 
@@ -315,7 +311,7 @@ void ether_setup(struct net_device *dev)
 	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */	
 	dev->flags		= IFF_BROADCAST|IFF_MULTICAST;
 	
-	memset(dev->broadcast,0xFF, ETH_ALEN);
+	memset(dev->broadcast, 0xFF, ETH_ALEN);
 
 }
 EXPORT_SYMBOL(ether_setup);
