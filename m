From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging-next tree with the net tree
Date: Thu, 6 May 2010 14:05:43 +1000
Message-ID: <20100506140543.d6f3841f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Prashant P. Shah" <pshah.mumbai@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:57999 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699Ab0EFEFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 00:05:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

Today's linux-next merge of the staging-next tree got a conflict in
drivers/staging/arlan/arlan-main.c between commit
22bedad3ce112d5ca1eaf043d4990fa2ed698c87 ("net: convert multicast list to
list_head") from the net tree and commit
dd730b627cf8ff0b9d20df94fd31b6192b188710 ("Staging: arlan: fixed
unnecessary whitespace style issue in arlan-main.c") from the
staging-next tree.

I fixed it up (see below - this is bigger than is would otherwise be
because there is a conflict with another patch that was previously
reported) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/staging/arlan/arlan-main.c
index 8028452,301b979..0000000
--- a/drivers/staging/arlan/arlan-main.c
+++ b/drivers/staging/arlan/arlan-main.c
@@@ -1438,105 -1336,99 +1336,99 @@@ static void arlan_rx_interrupt(struct n
  		priv->in_time10 = jiffies;
  	}
  	DEBUGSHM(1, "arlan rcv pkt rxStatus= %d ", arlan->rxStatus, u_char);
- 	switch (rxStatus)
+ 	switch (rxStatus) {
+ 	case 1:
+ 	case 2:
+ 	case 3:
  	{
- 		case 1:
- 		case 2:
- 		case 3:
- 		{
- 			/* Malloc up new buffer. */
- 			struct sk_buff *skb;
+ 		/* Malloc up new buffer. */
+ 		struct sk_buff *skb;
  
- 			DEBUGSHM(50, "arlan recv pkt offs=%d\n", arlan->rxOffset, u_short);
- 			DEBUGSHM(1, "arlan rxFrmType = %d \n", arlan->rxFrmType, u_char);
- 			DEBUGSHM(1, KERN_INFO "arlan rx scrambled = %d \n", arlan->scrambled, u_char);
+ 		DEBUGSHM(50, "arlan recv pkt offs=%d\n", arlan->rxOffset, u_short);
+ 		DEBUGSHM(1, "arlan rxFrmType = %d\n", arlan->rxFrmType, u_char);
+ 		DEBUGSHM(1, KERN_INFO "arlan rx scrambled = %d\n", arlan->scrambled, u_char);
  
- 			/* here we do multicast filtering to avoid slow 8-bit memcopy */
+ 		/* here we do multicast filtering to avoid slow 8-bit memcopy */
  #ifdef ARLAN_MULTICAST
- 			if (!(dev->flags & IFF_ALLMULTI) &&
- 				!(dev->flags & IFF_PROMISC) &&
- 				!netdev_mc_empty(dev))
- 			{
- 				char hw_dst_addr[6];
- 				struct netdev_hw_addr *ha;
- 				int i;
- 
- 				memcpy_fromio(hw_dst_addr, arlan->ultimateDestAddress, 6);
- 				if (hw_dst_addr[0] == 0x01)
- 				{
- 					if (mdebug)
- 						if (hw_dst_addr[1] == 0x00)
- 							printk(KERN_ERR "%s mcast 0x0100 \n", dev->name);
- 						else if (hw_dst_addr[1] == 0x40)
- 							printk(KERN_ERR "%s m/bcast 0x0140 \n", dev->name);
- 					netdev_for_each_mc_entry(ha, dev) {
- 						if (arlan_debug & ARLAN_DEBUG_HEADER_DUMP)
- 							printk(KERN_ERR "%s mcl %pM\n",
- 							       dev->name,
- 							       ha->addr);
- 						for (i = 0; i < 6; i++)
- 							if (ha->addr[i] != hw_dst_addr[i])
- 								break;
- 						if (i == 6)
+ 		if (!(dev->flags & IFF_ALLMULTI) &&
+ 			!(dev->flags & IFF_PROMISC) &&
+ 			!netdev_mc_empty(dev)) {
+ 			char hw_dst_addr[6];
 -			struct dev_mc_list *dmi;
++			struct netdev_hw_addr *ha;
+ 			int i;
+ 
+ 			memcpy_fromio(hw_dst_addr, arlan->ultimateDestAddress, 6);
+ 			if (hw_dst_addr[0] == 0x01) {
+ 				if (mdebug)
+ 					if (hw_dst_addr[1] == 0x00)
+ 						printk(KERN_ERR "%s mcast 0x0100\n", dev->name);
+ 					else if (hw_dst_addr[1] == 0x40)
+ 						printk(KERN_ERR "%s m/bcast 0x0140\n", dev->name);
 -				netdev_for_each_mc_entry(dmi, dev) {
++				netdev_for_each_mc_entry(ha, dev) {
+ 					if (arlan_debug & ARLAN_DEBUG_HEADER_DUMP)
+ 						printk(KERN_ERR "%s mcl %pM\n",
 -						       dev->name, dmi->dmi_addr);
++						       dev->name, ha->addr);
+ 					for (i = 0; i < 6; i++)
 -						if (dmi->dmi_addr[i] != hw_dst_addr[i])
++						if (ha->addr[i] != hw_dst_addr[i])
  							break;
- 					}
- 					/* we reach here if multicast filtering is on and packet 
- 					 * is multicast and not for receive */
- 					goto end_of_interrupt;
+ 					if (i == 6)
+ 						break;
  				}
+ 				/* we reach here if multicast filtering is on and packet */
+ 				/* is multicast and not for receive */
+ 				goto end_of_interrupt;
  			}
- #endif				// ARLAN_MULTICAST
- 			/* multicast filtering ends here */
- 			pkt_len += ARLAN_FAKE_HDR_LEN;
- 
- 			skb = dev_alloc_skb(pkt_len + 4);
- 			if (skb == NULL)
- 			{
- 				printk(KERN_ERR "%s: Memory squeeze, dropping packet.\n", dev->name);
- 				dev->stats.rx_dropped++;
- 				break;
- 			}
- 			skb_reserve(skb, 2);
- 			skbtmp = skb_put(skb, pkt_len);
+ 		}
+ #endif	/* ARLAN_MULTICAST */
+ 		/* multicast filtering ends here */
+ 		pkt_len += ARLAN_FAKE_HDR_LEN;
+ 
+ 		skb = dev_alloc_skb(pkt_len + 4);
+ 		if (skb == NULL) {
+ 			printk(KERN_ERR "%s: Memory squeeze, dropping packet.\n", dev->name);
+ 			dev->stats.rx_dropped++;
+ 			break;
+ 		}
+ 		skb_reserve(skb, 2);
+ 		skbtmp = skb_put(skb, pkt_len);
  
- 			memcpy_fromio(skbtmp + ARLAN_FAKE_HDR_LEN, ((char __iomem *) arlan) + rxOffset, pkt_len - ARLAN_FAKE_HDR_LEN);
- 			memcpy_fromio(skbtmp, arlan->ultimateDestAddress, 6);
- 			memcpy_fromio(skbtmp + 6, arlan->rxSrc, 6);
- 			WRITESHMB(arlan->rxStatus, 0x00);
- 			arlan_command(dev, ARLAN_COMMAND_RX);
+ 		memcpy_fromio(skbtmp + ARLAN_FAKE_HDR_LEN, ((char __iomem *) arlan) + rxOffset, pkt_len - ARLAN_FAKE_HDR_LEN);
+ 		memcpy_fromio(skbtmp, arlan->ultimateDestAddress, 6);
+ 		memcpy_fromio(skbtmp + 6, arlan->rxSrc, 6);
+ 		WRITESHMB(arlan->rxStatus, 0x00);
+ 		arlan_command(dev, ARLAN_COMMAND_RX);
  
- 			IFDEBUG(ARLAN_DEBUG_HEADER_DUMP)
- 			{
- 				char immedDestAddress[6];
- 				char immedSrcAddress[6];
- 				memcpy_fromio(immedDestAddress, arlan->immedDestAddress, 6);
- 				memcpy_fromio(immedSrcAddress, arlan->immedSrcAddress, 6);
- 
- 				printk(KERN_WARNING "%s t %pM f %pM imd %pM ims %pM\n",
- 				       dev->name, skbtmp,
- 				       &skbtmp[6],
- 				       immedDestAddress,
- 				       immedSrcAddress);
- 			}
- 			skb->protocol = eth_type_trans(skb, dev);
- 			IFDEBUG(ARLAN_DEBUG_HEADER_DUMP)
- 				if (skb->protocol != 0x608 && skb->protocol != 0x8)
- 				{
- 					for (i = 0; i <= 22; i++)
- 						printk("%02x:", (u_char) skbtmp[i + 12]);
- 					printk(KERN_ERR "\n");
- 					printk(KERN_WARNING "arlan kernel pkt type trans %x \n", skb->protocol);
- 				}
- 			netif_rx(skb);
- 			dev->stats.rx_packets++;
- 			dev->stats.rx_bytes += pkt_len;
+ 		IFDEBUG(ARLAN_DEBUG_HEADER_DUMP)
+ 		{
+ 			char immedDestAddress[6];
+ 			char immedSrcAddress[6];
+ 			memcpy_fromio(immedDestAddress, arlan->immedDestAddress, 6);
+ 			memcpy_fromio(immedSrcAddress, arlan->immedSrcAddress, 6);
+ 
+ 			printk(KERN_WARNING "%s t %pM f %pM imd %pM ims %pM\n",
+ 			       dev->name, skbtmp,
+ 			       &skbtmp[6],
+ 			       immedDestAddress,
+ 			       immedSrcAddress);
  		}
+ 		skb->protocol = eth_type_trans(skb, dev);
+ 		IFDEBUG(ARLAN_DEBUG_HEADER_DUMP)
+ 			if (skb->protocol != 0x608 && skb->protocol != 0x8) {
+ 				for (i = 0; i <= 22; i++)
+ 					printk("%02x:", (u_char) skbtmp[i + 12]);
+ 				printk(KERN_ERR "\n");
+ 				printk(KERN_WARNING "arlan kernel pkt type trans %x\n", skb->protocol);
+ 			}
+ 		netif_rx(skb);
+ 		dev->stats.rx_packets++;
+ 		dev->stats.rx_bytes += pkt_len;
+ 	}
+ 	break;
+ 
+ 	default:
+ 		printk(KERN_ERR "arlan intr: received unknown status\n");
+ 		dev->stats.rx_crc_errors++;
  		break;
- 		
- 		default:
- 			printk(KERN_ERR "arlan intr: received unknown status\n");
- 			dev->stats.rx_crc_errors++;
- 			break;
  	}
  	ARLAN_DEBUG_EXIT("arlan_rx_interrupt");
  }
