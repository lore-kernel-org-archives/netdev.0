From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] net/802: indentation cleanup
Date: Fri, 17 Aug 2007 18:53:11 -0700
Message-ID: <20070817185311.5564198a@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38783 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751959AbXHRBxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 21:53:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Run the 802 related protocols through Lindent (and hand cleanup)
to fix indentation and whitespace style issues.

--- a/net/802/fc.c	2007-08-17 14:39:56.000000000 -0400
+++ b/net/802/fc.c	2007-08-17 14:50:52.000000000 -0400
@@ -44,33 +44,29 @@ static int fc_header(struct sk_buff *skb
 	 * Add the 802.2 SNAP header if IP as the IPv4 code calls
 	 * dev->hard_header directly.
 	 */
-	if (type == ETH_P_IP || type == ETH_P_ARP)
-	{
+	if (type == ETH_P_IP || type == ETH_P_ARP) {
 		struct fcllc *fcllc;
 
 		hdr_len = sizeof(struct fch_hdr) + sizeof(struct fcllc);
 		fch = (struct fch_hdr *)skb_push(skb, hdr_len);
-		fcllc = (struct fcllc *)(fch+1);
+		fcllc = (struct fcllc *)(fch + 1);
 		fcllc->dsap = fcllc->ssap = EXTENDED_SAP;
 		fcllc->llc = UI_CMD;
 		fcllc->protid[0] = fcllc->protid[1] = fcllc->protid[2] = 0x00;
 		fcllc->ethertype = htons(type);
-	}
-	else
-	{
+	} else {
 		hdr_len = sizeof(struct fch_hdr);
 		fch = (struct fch_hdr *)skb_push(skb, hdr_len);
 	}
 
-	if(saddr)
-		memcpy(fch->saddr,saddr,dev->addr_len);
+	if (saddr)
+		memcpy(fch->saddr, saddr, dev->addr_len);
 	else
-		memcpy(fch->saddr,dev->dev_addr,dev->addr_len);
+		memcpy(fch->saddr, dev->dev_addr, dev->addr_len);
 
-	if(daddr)
-	{
-		memcpy(fch->daddr,daddr,dev->addr_len);
-		return(hdr_len);
+	if (daddr) {
+		memcpy(fch->daddr, daddr, dev->addr_len);
+		return hdr_len;
 	}
 	return -hdr_len;
 }
@@ -82,10 +78,13 @@ static int fc_header(struct sk_buff *skb
 
 static int fc_rebuild_header(struct sk_buff *skb)
 {
-	struct fch_hdr *fch=(struct fch_hdr *)skb->data;
-	struct fcllc *fcllc=(struct fcllc *)(skb->data+sizeof(struct fch_hdr));
-	if(fcllc->ethertype != htons(ETH_P_IP)) {
-		printk("fc_rebuild_header: Don't know how to resolve type %04X addresses ?\n", ntohs(fcllc->ethertype));
+	struct fch_hdr *fch = (struct fch_hdr *)skb->data;
+	struct fcllc *fcllc = (struct fcllc *)(skb->data + sizeof(struct fch_hdr));
+
+	if (fcllc->ethertype != htons(ETH_P_IP)) {
+		printk
+		    ("fc_rebuild_header: Don't know how to resolve type %04X addresses ?\n",
+		     ntohs(fcllc->ethertype));
 		return 0;
 	}
 #ifdef CONFIG_INET
--- a/net/802/tr.c	2007-08-17 14:39:56.000000000 -0400
+++ b/net/802/tr.c	2007-08-17 14:50:55.000000000 -0400
@@ -67,14 +67,13 @@ static struct rif_cache *rif_table[RIF_T
 
 static DEFINE_SPINLOCK(rif_lock);
 
-
 /*
  *	Garbage disposal timer.
  */
 
 static struct timer_list rif_timer;
 
-int sysctl_tr_rif_timeout = 60*10*HZ;
+int sysctl_tr_rif_timeout = 60 * 10 * HZ;
 
 static inline unsigned long rif_hash(const unsigned char *addr)
 {
@@ -108,41 +107,37 @@ static int tr_header(struct sk_buff *skb
 	 * Add the 802.2 SNAP header if IP as the IPv4/IPv6 code calls
 	 * dev->hard_header directly.
 	 */
-	if (type == ETH_P_IP || type == ETH_P_IPV6 || type == ETH_P_ARP)
-	{
+	if (type == ETH_P_IP || type == ETH_P_IPV6 || type == ETH_P_ARP) {
 		struct trllc *trllc;
 
 		hdr_len = sizeof(struct trh_hdr) + sizeof(struct trllc);
 		trh = (struct trh_hdr *)skb_push(skb, hdr_len);
-		trllc = (struct trllc *)(trh+1);
+		trllc = (struct trllc *)(trh + 1);
 		trllc->dsap = trllc->ssap = EXTENDED_SAP;
 		trllc->llc = UI_CMD;
 		trllc->protid[0] = trllc->protid[1] = trllc->protid[2] = 0x00;
 		trllc->ethertype = htons(type);
-	}
-	else
-	{
+	} else {
 		hdr_len = sizeof(struct trh_hdr);
 		trh = (struct trh_hdr *)skb_push(skb, hdr_len);
 	}
 
-	trh->ac=AC;
-	trh->fc=LLC_FRAME;
+	trh->ac = AC;
+	trh->fc = LLC_FRAME;
 
-	if(saddr)
-		memcpy(trh->saddr,saddr,dev->addr_len);
+	if (saddr)
+		memcpy(trh->saddr, saddr, dev->addr_len);
 	else
-		memcpy(trh->saddr,dev->dev_addr,dev->addr_len);
+		memcpy(trh->saddr, dev->dev_addr, dev->addr_len);
 
 	/*
-	 *	Build the destination and then source route the frame
+	 *      Build the destination and then source route the frame
 	 */
 
-	if(daddr)
-	{
-		memcpy(trh->daddr,daddr,dev->addr_len);
-		tr_source_route(skb,trh,dev);
-		return(hdr_len);
+	if (daddr) {
+		memcpy(trh->daddr, daddr, dev->addr_len);
+		tr_source_route(skb, trh, dev);
+		return hdr_len;
 	}
 
 	return -hdr_len;
@@ -155,27 +150,27 @@ static int tr_header(struct sk_buff *skb
 
 static int tr_rebuild_header(struct sk_buff *skb)
 {
-	struct trh_hdr *trh=(struct trh_hdr *)skb->data;
-	struct trllc *trllc=(struct trllc *)(skb->data+sizeof(struct trh_hdr));
+	struct trh_hdr *trh = (struct trh_hdr *)skb->data;
+	struct trllc *trllc = (struct trllc *)(skb->data + sizeof(struct trh_hdr));
 	struct net_device *dev = skb->dev;
 
 	/*
-	 *	FIXME: We don't yet support IPv6 over token rings
+	 *      FIXME: We don't yet support IPv6 over token rings
 	 */
 
-	if(trllc->ethertype != htons(ETH_P_IP)) {
-		printk("tr_rebuild_header: Don't know how to resolve type %04X addresses ?\n", ntohs(trllc->ethertype));
+	if (trllc->ethertype != htons(ETH_P_IP)) {
+		printk("tr_rebuild_header: Don't know how to resolve"
+		       " type %04X addresses ?\n",
+		       ntohs(trllc->ethertype));
 		return 0;
 	}
-
 #ifdef CONFIG_INET
-	if(arp_find(trh->daddr, skb)) {
-			return 1;
-	}
-	else
+	if (arp_find(trh->daddr, skb)) {
+		return 1;
+	} else
 #endif
 	{
-		tr_source_route(skb,trh,dev);
+		tr_source_route(skb, trh, dev);
 		return 0;
 	}
 }
@@ -186,44 +181,41 @@ static int tr_rebuild_header(struct sk_b
  *	it via SNAP.
  */
 
-__be16 tr_type_trans(struct sk_buff *skb, struct net_device *dev)
+__be16 tr_type_trans(struct sk_buff * skb, struct net_device * dev)
 {
 
 	struct trh_hdr *trh;
 	struct trllc *trllc;
-	unsigned riflen=0;
+	unsigned riflen = 0;
 
 	skb->dev = dev;
 	skb_reset_mac_header(skb);
 	trh = tr_hdr(skb);
 
-	if(trh->saddr[0] & TR_RII)
+	if (trh->saddr[0] & TR_RII)
 		riflen = (ntohs(trh->rcf) & TR_RCF_LEN_MASK) >> 8;
 
-	trllc = (struct trllc *)(skb->data+sizeof(struct trh_hdr)-TR_MAXRIFLEN+riflen);
+	trllc = (struct trllc *)(skb->data + sizeof(struct trh_hdr)
+				 - TR_MAXRIFLEN + riflen);
 
-	skb_pull(skb,sizeof(struct trh_hdr)-TR_MAXRIFLEN+riflen);
+	skb_pull(skb, sizeof(struct trh_hdr) - TR_MAXRIFLEN + riflen);
 
-	if(*trh->daddr & 0x80)
-	{
-		if(!memcmp(trh->daddr,dev->broadcast,TR_ALEN))
-			skb->pkt_type=PACKET_BROADCAST;
+	if (*trh->daddr & 0x80) {
+		if (!memcmp(trh->daddr, dev->broadcast, TR_ALEN))
+			skb->pkt_type = PACKET_BROADCAST;
 		else
-			skb->pkt_type=PACKET_MULTICAST;
-	}
-	else if ( (trh->daddr[0] & 0x01) && (trh->daddr[1] & 0x00) && (trh->daddr[2] & 0x5E))
-	{
-		skb->pkt_type=PACKET_MULTICAST;
-	}
-	else if(dev->flags & IFF_PROMISC)
-	{
-		if(memcmp(trh->daddr, dev->dev_addr, TR_ALEN))
-			skb->pkt_type=PACKET_OTHERHOST;
+			skb->pkt_type = PACKET_MULTICAST;
+	} else if ((trh->daddr[0] & 0x01) && (trh->daddr[1] & 0x00)
+		   && (trh->daddr[2] & 0x5E)) {
+		skb->pkt_type = PACKET_MULTICAST;
+	} else if (dev->flags & IFF_PROMISC) {
+		if (memcmp(trh->daddr, dev->dev_addr, TR_ALEN))
+			skb->pkt_type = PACKET_OTHERHOST;
 	}
 
 	if ((skb->pkt_type != PACKET_BROADCAST) &&
 	    (skb->pkt_type != PACKET_MULTICAST))
-		tr_add_rif_info(trh,dev) ;
+		tr_add_rif_info(trh, dev);
 
 	/*
 	 * Strip the SNAP header from ARP packets since we don't
@@ -233,8 +225,7 @@ __be16 tr_type_trans(struct sk_buff *skb
 	if (trllc->dsap == EXTENDED_SAP &&
 	    (trllc->ethertype == htons(ETH_P_IP) ||
 	     trllc->ethertype == htons(ETH_P_IPV6) ||
-	     trllc->ethertype == htons(ETH_P_ARP)))
-	{
+	     trllc->ethertype == htons(ETH_P_ARP))) {
 		skb_pull(skb, sizeof(struct trllc));
 		return trllc->ethertype;
 	}
@@ -246,7 +237,8 @@ __be16 tr_type_trans(struct sk_buff *skb
  *	We try to do source routing...
  */
 
-void tr_source_route(struct sk_buff *skb,struct trh_hdr *trh,struct net_device *dev)
+void tr_source_route(struct sk_buff *skb, struct trh_hdr *trh,
+		     struct net_device *dev)
 {
 	int slack;
 	unsigned int hash;
@@ -254,65 +246,63 @@ void tr_source_route(struct sk_buff *skb
 	unsigned char *olddata;
 	unsigned long flags;
 	static const unsigned char mcast_func_addr[]
-		= {0xC0,0x00,0x00,0x04,0x00,0x00};
+		= { 0xC0, 0x00, 0x00, 0x04, 0x00, 0x00 };
 
 	spin_lock_irqsave(&rif_lock, flags);
 
 	/*
-	 *	Broadcasts are single route as stated in RFC 1042
+	 *      Broadcasts are single route as stated in RFC 1042
 	 */
-	if( (!memcmp(&(trh->daddr[0]),&(dev->broadcast[0]),TR_ALEN)) ||
-	    (!memcmp(&(trh->daddr[0]),&(mcast_func_addr[0]), TR_ALEN))  )
-	{
-		trh->rcf=htons((((sizeof(trh->rcf)) << 8) & TR_RCF_LEN_MASK)
-			       | TR_RCF_FRAME2K | TR_RCF_LIMITED_BROADCAST);
-		trh->saddr[0]|=TR_RII;
-	}
-	else
-	{
+	if ((!memcmp(&(trh->daddr[0]), &(dev->broadcast[0]), TR_ALEN)) ||
+	    (!memcmp(&(trh->daddr[0]), &(mcast_func_addr[0]), TR_ALEN))) {
+		trh->rcf = htons((((sizeof(trh->rcf)) << 8) & TR_RCF_LEN_MASK)
+				 | TR_RCF_FRAME2K | TR_RCF_LIMITED_BROADCAST);
+		trh->saddr[0] |= TR_RII;
+	} else {
 		hash = rif_hash(trh->daddr);
 		/*
-		 *	Walk the hash table and look for an entry
+		 *      Walk the hash table and look for an entry
 		 */
-		for(entry=rif_table[hash];entry && memcmp(&(entry->addr[0]),&(trh->daddr[0]),TR_ALEN);entry=entry->next);
+		for (entry = rif_table[hash];
+		     entry && memcmp(&(entry->addr[0]), &(trh->daddr[0]), TR_ALEN);
+		     entry = entry->next) ;
 
 		/*
-		 *	If we found an entry we can route the frame.
+		 *      If we found an entry we can route the frame.
 		 */
-		if(entry)
-		{
+		if (entry) {
 #if TR_SR_DEBUG
-printk("source routing for %02X:%02X:%02X:%02X:%02X:%02X\n",trh->daddr[0],
-		  trh->daddr[1],trh->daddr[2],trh->daddr[3],trh->daddr[4],trh->daddr[5]);
+			printk("source routing for %02X:%02X:%02X:%02X:%02X:%02X\n",
+			       trh->daddr[0], trh->daddr[1], trh->daddr[2],
+			       trh->daddr[3], trh->daddr[4], trh->daddr[5]);
 #endif
-			if(!entry->local_ring && (ntohs(entry->rcf) & TR_RCF_LEN_MASK) >> 8)
-			{
-				trh->rcf=entry->rcf;
-				memcpy(&trh->rseg[0],&entry->rseg[0],8*sizeof(unsigned short));
-				trh->rcf^=htons(TR_RCF_DIR_BIT);
-				trh->rcf&=htons(0x1fff);	/* Issam Chehab <ichehab@madge1.demon.co.uk> */
+			if (!entry->local_ring
+			    && (ntohs(entry->rcf) & TR_RCF_LEN_MASK) >> 8) {
+				trh->rcf = entry->rcf;
+				memcpy(&trh->rseg[0], &entry->rseg[0],
+				       8 * sizeof(unsigned short));
+				trh->rcf ^= htons(TR_RCF_DIR_BIT);
+				trh->rcf &= htons(0x1fff);	/* Issam Chehab <ichehab@madge1.demon.co.uk> */
 
-				trh->saddr[0]|=TR_RII;
+				trh->saddr[0] |= TR_RII;
 #if TR_SR_DEBUG
-				printk("entry found with rcf %04x\n", entry->rcf);
-			}
-			else
-			{
-				printk("entry found but without rcf length, local=%02x\n", entry->local_ring);
+				printk("entry found with rcf %04x\n",
+				       entry->rcf);
+			} else {
+				printk("entry found but without rcf length,"
+				       "local=%02x\n", entry->local_ring);
 #endif
 			}
-			entry->last_used=jiffies;
-		}
-		else
-		{
+			entry->last_used = jiffies;
+		} else {
 			/*
-			 *	Without the information we simply have to shout
-			 *	on the wire. The replies should rapidly clean this
-			 *	situation up.
+			 *      Without the information we simply have to shout
+			 *      on the wire. The replies should rapidly clean this
+			 *      situation up.
 			 */
-			trh->rcf=htons((((sizeof(trh->rcf)) << 8) & TR_RCF_LEN_MASK)
-				       | TR_RCF_FRAME2K | TR_RCF_LIMITED_BROADCAST);
-			trh->saddr[0]|=TR_RII;
+			trh->rcf = htons((((sizeof(trh->rcf)) << 8) & TR_RCF_LEN_MASK)
+				  | TR_RCF_FRAME2K | TR_RCF_LIMITED_BROADCAST);
+			trh->saddr[0] |= TR_RII;
 #if TR_SR_DEBUG
 			printk("no entry in rif table found - broadcasting frame\n");
 #endif
@@ -323,7 +313,7 @@ printk("source routing for %02X:%02X:%02
 	if (!(trh->saddr[0] & 0x80))
 		slack = 18;
 	else
-		slack = 18 - ((ntohs(trh->rcf) & TR_RCF_LEN_MASK)>>8);
+		slack = 18 - ((ntohs(trh->rcf) & TR_RCF_LEN_MASK) >> 8);
 	olddata = skb->data;
 	spin_unlock_irqrestore(&rif_lock, flags);
 
@@ -347,83 +337,84 @@ static void tr_add_rif_info(struct trh_h
 	saddr0 = trh->saddr[0];
 
 	/*
-	 *	Firstly see if the entry exists
+	 *      Firstly see if the entry exists
 	 */
 
-	if(trh->saddr[0] & TR_RII)
-	{
-		trh->saddr[0]&=0x7f;
-		if (((ntohs(trh->rcf) & TR_RCF_LEN_MASK) >> 8) > 2)
-		{
+	if (trh->saddr[0] & TR_RII) {
+		trh->saddr[0] &= 0x7f;
+		if (((ntohs(trh->rcf) & TR_RCF_LEN_MASK) >> 8) > 2) {
 			rii_p = 1;
 		}
 	}
 
 	hash = rif_hash(trh->saddr);
-	for(entry=rif_table[hash];entry && memcmp(&(entry->addr[0]),&(trh->saddr[0]),TR_ALEN);entry=entry->next);
+	for (entry = rif_table[hash];
+	     entry && memcmp(&(entry->addr[0]), &(trh->saddr[0]), TR_ALEN);
+	     entry = entry->next) ;
 
-	if(entry==NULL)
-	{
+	if (entry == NULL) {
 #if TR_SR_DEBUG
-printk("adding rif_entry: addr:%02X:%02X:%02X:%02X:%02X:%02X rcf:%04X\n",
-		trh->saddr[0],trh->saddr[1],trh->saddr[2],
-		trh->saddr[3],trh->saddr[4],trh->saddr[5],
-		ntohs(trh->rcf));
+		printk("adding rif_entry: addr:%02X:%02X:%02X:%02X:%02X:%02X"
+		       " rcf:%04X\n",
+		       trh->saddr[0], trh->saddr[1], trh->saddr[2], trh->saddr[3],
+		       trh->saddr[4], trh->saddr[5], ntohs(trh->rcf));
 #endif
 		/*
-		 *	Allocate our new entry. A failure to allocate loses
-		 *	use the information. This is harmless.
+		 *      Allocate our new entry. A failure to allocate loses
+		 *      use the information. This is harmless.
 		 *
-		 *	FIXME: We ought to keep some kind of cache size
-		 *	limiting and adjust the timers to suit.
+		 *      FIXME: We ought to keep some kind of cache size
+		 *      limiting and adjust the timers to suit.
 		 */
-		entry=kmalloc(sizeof(struct rif_cache),GFP_ATOMIC);
+		entry = kmalloc(sizeof(struct rif_cache), GFP_ATOMIC);
 
-		if(!entry)
-		{
-			printk(KERN_DEBUG "tr.c: Couldn't malloc rif cache entry !\n");
+		if (!entry) {
+			printk(KERN_DEBUG
+			       "tr.c: Couldn't malloc rif cache entry !\n");
 			spin_unlock_irqrestore(&rif_lock, flags);
 			return;
 		}
 
-		memcpy(&(entry->addr[0]),&(trh->saddr[0]),TR_ALEN);
+		memcpy(&(entry->addr[0]), &(trh->saddr[0]), TR_ALEN);
 		entry->iface = dev->ifindex;
-		entry->next=rif_table[hash];
-		entry->last_used=jiffies;
-		rif_table[hash]=entry;
-
-		if (rii_p)
-		{
-			entry->rcf = trh->rcf & htons((unsigned short)~TR_RCF_BROADCAST_MASK);
-			memcpy(&(entry->rseg[0]),&(trh->rseg[0]),8*sizeof(unsigned short));
+		entry->next = rif_table[hash];
+		entry->last_used = jiffies;
+		rif_table[hash] = entry;
+
+		if (rii_p) {
+			entry->rcf = trh->rcf
+				& htons((unsigned short)~TR_RCF_BROADCAST_MASK);
+			memcpy(&(entry->rseg[0]), &(trh->rseg[0]),
+			       8 * sizeof(unsigned short));
 			entry->local_ring = 0;
-		}
-		else
-		{
+		} else {
 			entry->local_ring = 1;
 		}
-	}
-	else	/* Y. Tahara added */
-	{
+	} else {		/* Y. Tahara added */
+
 		/*
-		 *	Update existing entries
+		 *      Update existing entries
 		 */
 		if (!entry->local_ring)
 		    if (entry->rcf != (trh->rcf & htons((unsigned short)~TR_RCF_BROADCAST_MASK)) &&
-			 !(trh->rcf & htons(TR_RCF_BROADCAST_MASK)))
-		    {
+			    && !(trh->rcf & htons(TR_RCF_BROADCAST_MASK))) {
 #if TR_SR_DEBUG
-printk("updating rif_entry: addr:%02X:%02X:%02X:%02X:%02X:%02X rcf:%04X\n",
-		trh->saddr[0],trh->saddr[1],trh->saddr[2],
-		trh->saddr[3],trh->saddr[4],trh->saddr[5],
-		ntohs(trh->rcf));
+				printk("updating rif_entry:"
+				       " addr:%02X:%02X:%02X:%02X:%02X:%02X"
+				       " rcf:%04X\n",
+				       trh->saddr[0], trh->saddr[1],
+				       trh->saddr[2], trh->saddr[3],
+				       trh->saddr[4], trh->saddr[5],
+				       ntohs(trh->rcf));
 #endif
-			    entry->rcf = trh->rcf & htons((unsigned short)~TR_RCF_BROADCAST_MASK);
-			    memcpy(&(entry->rseg[0]),&(trh->rseg[0]),8*sizeof(unsigned short));
-		    }
-		entry->last_used=jiffies;
+				entry->rcf = trh->rcf
+					& htons((unsigned short)~TR_RCF_BROADCAST_MASK);
+				memcpy(&(entry->rseg[0]), &(trh->rseg[0]),
+				       8 * sizeof(unsigned short));
+			}
+		entry->last_used = jiffies;
 	}
-	trh->saddr[0]=saddr0; /* put the routing indicator back for tcpdump */
+	trh->saddr[0] = saddr0;	/* put the routing indicator back for tcpdump */
 	spin_unlock_irqrestore(&rif_lock, flags);
 }
 
@@ -434,17 +425,17 @@ printk("updating rif_entry: addr:%02X:%0
 static void rif_check_expire(unsigned long dummy)
 {
 	int i;
-	unsigned long flags, next_interval = jiffies + sysctl_tr_rif_timeout/2;
+	unsigned long flags, next_interval = jiffies + sysctl_tr_rif_timeout / 2;
 
 	spin_lock_irqsave(&rif_lock, flags);
 
-	for(i =0; i < RIF_TABLE_SIZE; i++) {
+	for (i = 0; i < RIF_TABLE_SIZE; i++) {
 		struct rif_cache *entry, **pentry;
 
-		pentry = rif_table+i;
-		while((entry=*pentry) != NULL) {
+		pentry = rif_table + i;
+		while ((entry = *pentry) != NULL) {
 			unsigned long expires
-				= entry->last_used + sysctl_tr_rif_timeout;
+			    = entry->last_used + sysctl_tr_rif_timeout;
 
 			if (time_before_eq(expires, jiffies)) {
 				*pentry = entry->next;
@@ -477,8 +468,8 @@ static struct rif_cache *rif_get_idx(lof
 	struct rif_cache *entry;
 	loff_t off = 0;
 
-	for(i = 0; i < RIF_TABLE_SIZE; i++)
-		for(entry = rif_table[i]; entry; entry = entry->next) {
+	for (i = 0; i < RIF_TABLE_SIZE; i++)
+		for (entry = rif_table[i]; entry; entry = entry->next) {
 			if (off == pos)
 				return entry;
 			++off;
@@ -487,14 +478,14 @@ static struct rif_cache *rif_get_idx(lof
 	return NULL;
 }
 
-static void *rif_seq_start(struct seq_file *seq, loff_t *pos)
+static void *rif_seq_start(struct seq_file *seq, loff_t * pos)
 {
 	spin_lock_irq(&rif_lock);
 
 	return *pos ? rif_get_idx(*pos - 1) : SEQ_START_TOKEN;
 }
 
-static void *rif_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+static void *rif_seq_next(struct seq_file *seq, void *v, loff_t * pos)
 {
 	int i;
 	struct rif_cache *ent = v;
@@ -530,39 +521,39 @@ static int rif_seq_show(struct seq_file 
 
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq,
-		     "if     TR address       TTL   rcf   routing segments\n");
+			 "if     TR address       TTL   rcf   routing segments\n");
 	else {
 		struct net_device *dev = dev_get_by_index(entry->iface);
 		long ttl = (long) (entry->last_used + sysctl_tr_rif_timeout)
-				- (long) jiffies;
+			- (long) jiffies;
 
 		seq_printf(seq, "%s %02X:%02X:%02X:%02X:%02X:%02X %7li ",
 			   dev?dev->name:"?",
-			   entry->addr[0],entry->addr[1],entry->addr[2],
-			   entry->addr[3],entry->addr[4],entry->addr[5],
+			   entry->addr[0], entry->addr[1], entry->addr[2],
+			   entry->addr[3], entry->addr[4], entry->addr[5],
 			   ttl/HZ);
 
-			if (entry->local_ring)
-				seq_puts(seq, "local\n");
-			else {
-
-				seq_printf(seq, "%04X", ntohs(entry->rcf));
-				rcf_len = ((ntohs(entry->rcf) & TR_RCF_LEN_MASK)>>8)-2;
-				if (rcf_len)
-					rcf_len >>= 1;
-				for(j = 1; j < rcf_len; j++) {
-					if(j==1) {
-						segment=ntohs(entry->rseg[j-1])>>4;
-						seq_printf(seq,"  %03X",segment);
-					}
-
-					segment=ntohs(entry->rseg[j])>>4;
-					brdgnmb=ntohs(entry->rseg[j-1])&0x00f;
-					seq_printf(seq,"-%01X-%03X",brdgnmb,segment);
+		if (entry->local_ring)
+			seq_puts(seq, "local\n");
+		else {
+
+			seq_printf(seq, "%04X", ntohs(entry->rcf));
+			rcf_len = ((ntohs(entry->rcf) & TR_RCF_LEN_MASK)>>8)-2;
+			if (rcf_len)
+				rcf_len >>= 1;
+			for(j = 1; j < rcf_len; j++) {
+				if(j==1) {
+					segment = ntohs(entry->rseg[j-1])>>4;
+					seq_printf(seq,"  %03X", segment);
 				}
-				seq_putc(seq, '\n');
+
+				segment = ntohs(entry->rseg[j]) >> 4;
+				brdgnmb = ntohs(entry->rseg[j-1]) & 0x00f;
+				seq_printf(seq,"-%01X-%03X", brdgnmb, segment);
 			}
+			seq_putc(seq, '\n');
 		}
+	}
 	return 0;
 }
 
--- a/net/802/fddi.c	2007-08-17 14:30:18.000000000 -0400
+++ b/net/802/fddi.c	2007-08-17 14:49:51.000000000 -0400
@@ -57,12 +57,11 @@ static int fddi_header(struct sk_buff *s
 	int hl = FDDI_K_SNAP_HLEN;
 	struct fddihdr *fddi;
 
-	if(type != ETH_P_IP && type != ETH_P_IPV6 && type != ETH_P_ARP)
-		hl=FDDI_K_8022_HLEN-3;
+	if (type != ETH_P_IP && type != ETH_P_IPV6 && type != ETH_P_ARP)
+		hl = FDDI_K_8022_HLEN - 3;
 	fddi = (struct fddihdr *)skb_push(skb, hl);
-	fddi->fc			 = FDDI_FC_K_ASYNC_LLC_DEF;
-	if(type == ETH_P_IP || type == ETH_P_IPV6 || type == ETH_P_ARP)
-	{
+	fddi->fc = FDDI_FC_K_ASYNC_LLC_DEF;
+	if (type == ETH_P_IP || type == ETH_P_IPV6 || type == ETH_P_ARP) {
 		fddi->hdr.llc_snap.dsap		 = FDDI_EXTENDED_SAP;
 		fddi->hdr.llc_snap.ssap		 = FDDI_EXTENDED_SAP;
 		fddi->hdr.llc_snap.ctrl		 = FDDI_UI_CMD;
@@ -79,23 +78,21 @@ static int fddi_header(struct sk_buff *s
 	else
 		memcpy(fddi->saddr, dev->dev_addr, dev->addr_len);
 
-	if (daddr != NULL)
-	{
+	if (daddr != NULL) {
 		memcpy(fddi->daddr, daddr, dev->addr_len);
-		return(hl);
+		return hl;
 	}
 
-	return(-hl);
+	return -hl;
 }
 
-
 /*
  * Rebuild the FDDI MAC header. This is called after an ARP
  * (or in future other address resolution) has completed on
  * this sk_buff.  We now let ARP fill in the other fields.
  */
 
-static int fddi_rebuild_header(struct sk_buff	*skb)
+static int fddi_rebuild_header(struct sk_buff *skb)
 {
 	struct fddihdr *fddi = (struct fddihdr *)skb->data;
 
@@ -108,11 +105,10 @@ static int fddi_rebuild_header(struct sk
 	{
 		printk("%s: Don't know how to resolve type %04X addresses.\n",
 		       skb->dev->name, ntohs(fddi->hdr.llc_snap.ethertype));
-		return(0);
+		return 0;
 	}
 }
 
-
 /*
  * Determine the packet's protocol ID and fill in skb fields.
  * This routine is called before an incoming packet is passed
@@ -120,7 +116,7 @@ static int fddi_rebuild_header(struct sk
  * the proper pointer to the start of packet data (skb->data).
  */
 
-__be16 fddi_type_trans(struct sk_buff *skb, struct net_device *dev)
+__be16 fddi_type_trans(struct sk_buff * skb, struct net_device * dev)
 {
 	struct fddihdr *fddi = (struct fddihdr *)skb->data;
 	__be16 type;
@@ -133,36 +129,31 @@ __be16 fddi_type_trans(struct sk_buff *s
 	skb->dev = dev;
 	skb_reset_mac_header(skb);	/* point to frame control (FC) */
 
-	if(fddi->hdr.llc_8022_1.dsap==0xe0)
-	{
-		skb_pull(skb, FDDI_K_8022_HLEN-3);
+	if (fddi->hdr.llc_8022_1.dsap == 0xe0) {
+		skb_pull(skb, FDDI_K_8022_HLEN - 3);
 		type = htons(ETH_P_802_2);
-	}
-	else
-	{
-		skb_pull(skb, FDDI_K_SNAP_HLEN);		/* adjust for 21 byte header */
-		type=fddi->hdr.llc_snap.ethertype;
+	} else {
+		skb_pull(skb, FDDI_K_SNAP_HLEN);	/* adjust for 21 byte header */
+		type = fddi->hdr.llc_snap.ethertype;
 	}
 
 	/* Set packet type based on destination address and flag settings */
 
-	if (*fddi->daddr & 0x01)
-	{
+	if (*fddi->daddr & 0x01) {
 		if (memcmp(fddi->daddr, dev->broadcast, FDDI_K_ALEN) == 0)
 			skb->pkt_type = PACKET_BROADCAST;
 		else
 			skb->pkt_type = PACKET_MULTICAST;
 	}
 
-	else if (dev->flags & IFF_PROMISC)
-	{
+	else if (dev->flags & IFF_PROMISC) {
 		if (memcmp(fddi->daddr, dev->dev_addr, FDDI_K_ALEN))
 			skb->pkt_type = PACKET_OTHERHOST;
 	}
 
 	/* Assume 802.2 SNAP frames, for now */
 
-	return(type);
+	return type;
 }
 
 EXPORT_SYMBOL(fddi_type_trans);
@@ -170,9 +161,9 @@ EXPORT_SYMBOL(fddi_type_trans);
 static int fddi_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if ((new_mtu < FDDI_K_SNAP_HLEN) || (new_mtu > FDDI_K_SNAP_DLEN))
-		return(-EINVAL);
+		return -EINVAL;
 	dev->mtu = new_mtu;
-	return(0);
+	return 0;
 }
 
 static void fddi_setup(struct net_device *dev)
@@ -206,4 +197,5 @@ struct net_device *alloc_fddidev(int siz
 {
 	return alloc_netdev(sizeof_priv, "fddi%d", fddi_setup);
 }
+
 EXPORT_SYMBOL(alloc_fddidev);
--- a/net/802/hippi.c	2007-08-17 14:30:18.000000000 -0400
+++ b/net/802/hippi.c	2007-08-17 14:45:39.000000000 -0400
@@ -49,9 +49,9 @@ static int hippi_header(struct sk_buff *
 			unsigned len)
 {
 	struct hippi_hdr *hip = (struct hippi_hdr *)skb_push(skb, HIPPI_HLEN);
-	struct hippi_cb *hcb = (struct hippi_cb *) skb->cb;
+	struct hippi_cb *hcb = (struct hippi_cb *)skb->cb;
 
-	if (!len){
+	if (!len) {
 		len = skb->len - HIPPI_HLEN;
 		printk("hippi_header(): length not supplied\n");
 	}
@@ -80,8 +80,7 @@ static int hippi_header(struct sk_buff *
 	hip->snap.oui[2]	= 0x00;
 	hip->snap.ethertype	= htons(type);
 
-	if (daddr)
-	{
+	if (daddr) {
 		memcpy(hip->le.dest_switch_addr, daddr + 3, 3);
 		memcpy(&hcb->ifield, daddr + 2, 4);
 		return HIPPI_HLEN;
@@ -90,7 +89,6 @@ static int hippi_header(struct sk_buff *
 	return -((int)HIPPI_HLEN);
 }
 
-
 /*
  * Rebuild the HIPPI MAC header. This is called after an ARP has
  * completed on this sk_buff. We now let ARP fill in the other fields.
@@ -104,9 +102,9 @@ static int hippi_rebuild_header(struct s
 	 * Only IP is currently supported
 	 */
 
-	if(hip->snap.ethertype != htons(ETH_P_IP))
-	{
-		printk(KERN_DEBUG "%s: unable to resolve type %X addresses.\n",skb->dev->name,ntohs(hip->snap.ethertype));
+	if (hip->snap.ethertype != htons(ETH_P_IP)) {
+		printk(KERN_DEBUG "%s: unable to resolve type %X addresses.\n",
+		       skb->dev->name, ntohs(hip->snap.ethertype));
 		return 0;
 	}
 
@@ -117,12 +115,11 @@ static int hippi_rebuild_header(struct s
 	return arp_find(hip->le.daddr, skb);
 }
 
-
 /*
  *	Determine the packet's protocol ID.
  */
 
-__be16 hippi_type_trans(struct sk_buff *skb, struct net_device *dev)
+__be16 hippi_type_trans(struct sk_buff * skb, struct net_device * dev)
 {
 	struct hippi_hdr *hip;
 
@@ -152,7 +149,7 @@ static int hippi_change_mtu(struct net_d
 	if ((new_mtu < 68) || (new_mtu > 65280))
 		return -EINVAL;
 	dev->mtu = new_mtu;
-	return(0);
+	return 0;
 }
 
 /*
@@ -174,9 +171,9 @@ static int hippi_neigh_setup_dev(struct 
 	p->mcast_probes = 0;
 
 	/* In IPv6 unicast probes are valid even on NBMA,
-	* because they are encapsulated in normal IPv6 protocol.
-	* Should be a generic flag.
-	*/
+	 * because they are encapsulated in normal IPv6 protocol.
+	 * Should be a generic flag.
+	 */
 	if (p->tbl->family != AF_INET6)
 		p->ucast_probes = 0;
 	return 0;
@@ -206,7 +203,6 @@ static void hippi_setup(struct net_devic
 	dev->tx_queue_len	= 25 /* 5 */;
 	memset(dev->broadcast, 0xFF, HIPPI_ALEN);
 
-
 	/*
 	 * HIPPI doesn't support broadcast+multicast and we only use
 	 * static ARP tables. ARP is disabled by hippi_neigh_setup_dev.
