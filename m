From: Thomas Klein <osstklei@de.ibm.com>
Subject: Re: [PATCH] ehea: Access iph->tot_len with correct endianness
Date: Wed, 02 Jul 2008 16:45:37 +0200
Message-ID: <486B9491.4020004@de.ibm.com>
References: <ada7ic5ed26.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, themann@de.ibm.com
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:51359 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753110AbYGBOpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 10:45:49 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m62EjmN8118862
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 14:45:48 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m62Ejm1J1003698
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 15:45:48 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m62EjgsY000441
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 15:45:43 +0100
In-Reply-To: <ada7ic5ed26.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
> iph->tot_len is stored in network byte order, so access it using
> ntohs().  This doesn't have any real world impact on ehea, since ehea
> only exists for big-endian platfroms (at the moment at least) but fixing
> this gets rid of a sparse warning and avoids having a bad example in the
> tree.
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>
> ---
>  drivers/net/ehea/ehea_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
> index 075fd54..451b7e6 100644
> --- a/drivers/net/ehea/ehea_main.c
> +++ b/drivers/net/ehea/ehea_main.c
> @@ -616,7 +616,7 @@ static int get_skb_hdr(struct sk_buff *skb, void **iphdr,
>  	*tcph = tcp_hdr(skb);
>  
>  	/* check if ip header and tcp header are complete */
> -	if (iph->tot_len < ip_len + tcp_hdrlen(skb))
> +	if (ntohs(iph->tot_len) < ip_len + tcp_hdrlen(skb))
>  		return -1;
>  
>  	*hdr_flags = LRO_IPV4 | LRO_TCP;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Correct. Thanks Roland!

Acked-by: Thomas Klein <tklein@de.ibm.com>
