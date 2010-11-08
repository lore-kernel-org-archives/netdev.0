From: Andy Grover <andy.grover@oracle.com>
Subject: Re: [PATCH] rds: Fix rds message leak in rds_message_map_pages
Date: Mon, 08 Nov 2010 11:40:53 -0800
Message-ID: <4CD85245.9090409@oracle.com>
References: <4CD82362.9070402@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rds-devel@oss.oracle.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:64239 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab0KHTlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 14:41:06 -0500
In-Reply-To: <4CD82362.9070402@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2010 08:20 AM, Pavel Emelyanov wrote:
> The sgs allocation error path leaks the allocated message.
>
> Signed-off-by: Pavel Emelyanov<xemul@openvz.org>
>
> ---
>
> diff --git a/net/rds/message.c b/net/rds/message.c
> index 848cff4..1fd3d29 100644
> --- a/net/rds/message.c
> +++ b/net/rds/message.c
> @@ -249,8 +249,10 @@ struct rds_message *rds_message_map_pages(unsigned long *page_addrs, unsigned in
>   	rm->m_inc.i_hdr.h_len = cpu_to_be32(total_len);
>   	rm->data.op_nents = ceil(total_len, PAGE_SIZE);
>   	rm->data.op_sg = rds_message_alloc_sgs(rm, num_sgs);
> -	if (!rm->data.op_sg)
> +	if (!rm->data.op_sg) {
> +		rds_message_put(rm);
>   		return ERR_PTR(-ENOMEM);
> +	}
>
>   	for (i = 0; i<  rm->data.op_nents; ++i) {
>   		sg_set_page(&rm->data.op_sg[i],

Acked-by: Andy Grover <andy.grover@oracle.com>

-- Andy
