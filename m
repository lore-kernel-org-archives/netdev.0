From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] eth1394: endian fixes
Date: Sat, 27 May 2006 20:12:49 +0400
Message-ID: <20060527161249.GA7276@martell.zuzino.mipt.ru>
References: <20060519132539.GC17751@mipter.zuzino.mipt.ru> <44782474.9050304@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:12964 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964787AbWE0QMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 12:12:25 -0400
Received: by nf-out-0910.google.com with SMTP id i2so39735nfe
        for <netdev@vger.kernel.org>; Sat, 27 May 2006 09:12:23 -0700 (PDT)
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Content-Disposition: inline
In-Reply-To: <44782474.9050304@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 27, 2006 at 12:05:40PM +0200, Stefan Richter wrote:
> Alexey Dobriyan wrote on 2006-05-16:
> >Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ...
> >@@ -935,7 +935,7 @@ static inline u16 ether1394_parse_encap(
> > 		*(u32*)arp_ptr = arp1394->sip;	/* move sender IP addr */
> > 		arp_ptr += arp->ar_pln;		/* skip over sender IP addr 
> > 		*/
> > 
> >-		if (arp->ar_op == 1)
> >+		if (arp->ar_op == htons(1))
> > 			/* just set ARP req target unique ID to 0 */
> > 			*((u64*)arp_ptr) = 0;
> > 		else
> 
> I suggest __constant_htons(ARPOP_REQUEST).

OK. htons(ARPOP_REQUEST) should be enough. __constant_* really needed in
initializators. Updated patch below.

> Alexey, I am afraid none of the current 1394 developers is actively
> using eth1394. Did you have the chance to test your patch on different
> platforms and with different peer OSs/platforms?

Unfortunately not.

> Also, did someone of the netdev guys already forward the patch (since we
> 1394 people are slow and eth1394 is marked unmaintained)? If not, I
> could send it along with a few other 1394 patches to akpm soon.

[PATCH] eth1394: endian fixes

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
+		if (arp->ar_op == htons(ARPOP_REQUEST))
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

