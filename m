From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-next 4/6] net: Call skb_checksum_init in IPv4
Date: Mon, 07 Apr 2014 13:13:56 -0400 (EDT)
Message-ID: <20140407.131356.1060173493402786873.davem@davemloft.net>
References: <alpine.DEB.2.02.1404041721170.21628@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753777AbaDGRN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 13:13:57 -0400
In-Reply-To: <alpine.DEB.2.02.1404041721170.21628@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 4 Apr 2014 17:27:36 -0700 (PDT)

> @@ -1454,6 +1454,13 @@ out_unlock:
>  	return err;
>  }
>  
> +__wsum inet_pseudo_compute(struct sk_buff *skb, int proto)
> +{
> +	return csum_tcpudp_nofold(ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
> +				  skb->len, proto, 0);
> +}
> +EXPORT_SYMBOL(inet_pseudo_compute);

This is just adjusting arguments passed into to another inline
function, please put this in a header and make it an inline too.
