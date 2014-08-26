From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/8] net: Clarification of CHECKSUM_UNNECESSARY
Date: Mon, 25 Aug 2014 18:13:41 -0700 (PDT)
Message-ID: <20140825.181341.304248903530349010.davem@davemloft.net>
References: <alpine.DEB.2.02.1408251738110.5541@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933438AbaHZBNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 21:13:42 -0400
In-Reply-To: <alpine.DEB.2.02.1408251738110.5541@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 25 Aug 2014 17:55:56 -0700 (PDT)

> @@ -569,16 +590,13 @@ struct sk_buff {
>  	__u8			wifi_acked:1;
>  	__u8			no_fcs:1;
>  	__u8			head_frag:1;
> -	/* Encapsulation protocol and NIC drivers should use
> -	 * this flag to indicate to each other if the skb contains
> -	 * encapsulated packet or not and maybe use the inner packet
> -	 * headers if needed
> -	 */
> +	/* Indicates the the inner headers are valid in the skbuff. */
>  	__u8			encapsulation:1;
>  	__u8			encap_hdr_csum:1;
>  	__u8			csum_valid:1;
>  	__u8			csum_complete_sw:1;
> -	/* 2/4 bit hole (depending on ndisc_nodetype presence) */
> +	__u8			csum_level:2;
> +	/* 0/2 bit hole (depending on ndisc_nodetype presence) */
>  	kmemcheck_bitfield_end(flags2);

Crap, with xmit_more, this actually bleeds us over into a new __u8.
