From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix kmemcheck annotations
Date: Thu, 29 Oct 2009 03:17:48 -0700 (PDT)
Message-ID: <20091029.031748.235701096.davem@davemloft.net>
References: <4AE96A1D.8050300@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42803
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754047AbZJ2KRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 06:17:24 -0400
In-Reply-To: <4AE96A1D.8050300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Oct 2009 11:10:37 +0100

> @@ -367,7 +367,6 @@ struct sk_buff {
>  #endif
>  
>  	int			iif;
> -	__u16			queue_mapping;
>  #ifdef CONFIG_NET_SCHED
>  	__u16			tc_index;	/* traffic control index */
>  #ifdef CONFIG_NET_CLS_ACT
> @@ -376,6 +375,7 @@ struct sk_buff {
>  #endif
>  
>  	kmemcheck_bitfield_begin(flags2);
> +	__u16			queue_mapping:16;
>  #ifdef CONFIG_IPV6_NDISC_NODETYPE
>  	__u8			ndisc_nodetype:2;
>  #endif

We may be trading size for performance here, I wonder if
it's wise to move queue_mapping like that and what
locality change we get as a result.
