From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: enic: endian bug in enic_queue_wq_skb_csum_l4()
Date: Thu, 1 Mar 2012 10:20:23 +0300
Message-ID: <20120301072023.GB7152@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roprabhu@cisco.com>, Neel Patel <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>, netdev@vger.kernel.org
To: Christian Benvenuti <benve@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:24273 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758617Ab2CAJPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 04:15:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse warns about an endian issue in the enic driver:
drivers/net/ethernet/cisco/enic/enic_main.c:1305:35: warning: incorrect type in assignment (different base types)
drivers/net/ethernet/cisco/enic/enic_main.c:1305:35:    expected restricted __wsum [usertype] csum
drivers/net/ethernet/cisco/enic/enic_main.c:1305:35:    got restricted __be16 [usertype] <noident>

Here is the code:
drivers/net/ethernet/cisco/enic/enic_main.c
  1304                  if ((netdev->features & NETIF_F_RXCSUM) && !csum_not_calc) {
  1305                          skb->csum = htons(checksum);
  1306                          skb->ip_summed = CHECKSUM_COMPLETE;
  1307                  }

skb->csum is 32bit we're storing a network endian short in it.  I don't
know networking well enough to know how to fix this.

regards,
dan carpenter
