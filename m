From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] eth1394: endian fixes
Date: Fri, 19 May 2006 17:25:39 +0400
Message-ID: <20060519132539.GC17751@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:46741 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751329AbWESN1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 09:27:17 -0400
Received: by nf-out-0910.google.com with SMTP id o63so58903nfa
        for <netdev@vger.kernel.org>; Fri, 19 May 2006 06:27:14 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/ieee1394/eth1394.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- a/drivers/ieee1394/eth1394.c
+++ 1/drivers/ieee1394/eth1394.c
@@ -935,7 +935,7 @@ static inline u16 ether1394_parse_encap(
 		*(u32*)arp_ptr = arp1394->sip;	/* move sender IP addr */
 		arp_ptr += arp->ar_pln;		/* skip over sender IP addr */
 
-		if (arp->ar_op == 1)
+		if (arp->ar_op == htons(1))
 			/* just set ARP req target unique ID to 0 */
 			*((u64*)arp_ptr) = 0;
 		else
@@ -1395,7 +1395,7 @@ static inline void ether1394_arp_to_1394
 /* We need to encapsulate the standard header with our own. We use the
  * ethernet header's proto for our own. */
 static inline unsigned int ether1394_encapsulate_prep(unsigned int max_payload,
-						      int proto,
+						      __be16 proto,
 						      union eth1394_hdr *hdr,
 						      u16 dg_size, u16 dgl)
 {
@@ -1626,7 +1626,7 @@ static int ether1394_tx (struct sk_buff 
 	gfp_t kmflags = in_interrupt() ? GFP_ATOMIC : GFP_KERNEL;
 	struct eth1394hdr *eth;
 	struct eth1394_priv *priv = netdev_priv(dev);
-	int proto;
+	__be16 proto;
 	unsigned long flags;
 	nodeid_t dest_node;
 	eth1394_tx_type tx_type;

