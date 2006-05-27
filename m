From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] eth1394: endian fixes
Date: Sat, 27 May 2006 12:05:40 +0200
Message-ID: <44782474.9050304@s5r6.in-berlin.de>
References: <20060519132539.GC17751@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:11406 "EHLO
	einhorn.in-berlin.de") by vger.kernel.org with ESMTP
	id S1750887AbWE0KGR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 06:06:17 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060519132539.GC17751@mipter.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote on 2006-05-16:
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
...
> @@ -935,7 +935,7 @@ static inline u16 ether1394_parse_encap(
>  		*(u32*)arp_ptr = arp1394->sip;	/* move sender IP addr */
>  		arp_ptr += arp->ar_pln;		/* skip over sender IP addr */
>  
> -		if (arp->ar_op == 1)
> +		if (arp->ar_op == htons(1))
>  			/* just set ARP req target unique ID to 0 */
>  			*((u64*)arp_ptr) = 0;
>  		else

I suggest __constant_htons(ARPOP_REQUEST).

> @@ -1395,7 +1395,7 @@ static inline void ether1394_arp_to_1394
>  /* We need to encapsulate the standard header with our own. We use the
>   * ethernet header's proto for our own. */
>  static inline unsigned int ether1394_encapsulate_prep(unsigned int max_payload,
> -						      int proto,
> +						      __be16 proto,
>  						      union eth1394_hdr *hdr,
>  						      u16 dg_size, u16 dgl)
>  {
> @@ -1626,7 +1626,7 @@ static int ether1394_tx (struct sk_buff 
>  	gfp_t kmflags = in_interrupt() ? GFP_ATOMIC : GFP_KERNEL;
>  	struct eth1394hdr *eth;
>  	struct eth1394_priv *priv = netdev_priv(dev);
> -	int proto;
> +	__be16 proto;
>  	unsigned long flags;
>  	nodeid_t dest_node;
>  	eth1394_tx_type tx_type;

Alexey, I am afraid none of the current 1394 developers is actively 
using eth1394. Did you have the chance to test your patch on different 
platforms and with different peer OSs/platforms?

Also, did someone of the netdev guys already forward the patch (since we 
1394 people are slow and eth1394 is marked unmaintained)? If not, I 
could send it along with a few other 1394 patches to akpm soon.
-- 
Stefan Richter
-=====-=-==- -=-= ==-==
http://arcgraph.de/sr/
