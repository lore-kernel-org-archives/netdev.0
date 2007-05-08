From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000: Simple optimizations in e1000_xmit_frame
Date: Tue, 08 May 2007 08:36:07 -0700
Message-ID: <464098E7.7070600@intel.com>
References: <20070508073127.17544.18180.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14419 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755512AbXEHPgT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 11:36:19 -0400
In-Reply-To: <20070508073127.17544.18180.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar wrote:
> Some simple optimizations in e1000_xmit_frame.
> 
> Patch against net-2.6.22.git
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>


looks good. I'll queue this and push it upstream.

Thanks,

Auke


> ---
> diff -ruNp org/drivers/net/e1000/e1000_main.c new/drivers/net/e1000/e1000_main.c
> --- org/drivers/net/e1000/e1000_main.c	2007-04-09 12:40:02.000000000 +0530
> +++ new/drivers/net/e1000/e1000_main.c	2007-04-09 12:42:28.000000000 +0530
> @@ -3264,14 +3264,13 @@ e1000_xmit_frame(struct sk_buff *skb, st
>  	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
>  	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
>  	unsigned int tx_flags = 0;
> -	unsigned int len = skb->len;
> +	unsigned int len = skb->len - skb->data_len;
>  	unsigned long flags;
> -	unsigned int nr_frags = 0;
> -	unsigned int mss = 0;
> +	unsigned int nr_frags;
> +	unsigned int mss;
>  	int count = 0;
>  	int tso;
>  	unsigned int f;
> -	len -= skb->data_len;
>  
>  	/* This goes back to the question of how to logically map a tx queue
>  	 * to a flow.  Right now, performance is impacted slightly negatively
> @@ -3305,7 +3304,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
>  		* points to just header, pull a few bytes of payload from
>  		* frags into skb->data */
>  		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
> -		if (skb->data_len && (hdr_len == (skb->len - skb->data_len))) {
> +		if (skb->data_len && hdr_len == len) {
>  			switch (adapter->hw.mac_type) {
>  				unsigned int pull_size;
>  			case e1000_82544:
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
