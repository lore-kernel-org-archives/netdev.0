From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 8/9] bnx2x: further annotations
Date: Thu, 22 Jan 2009 19:49:53 +0200
Message-ID: <1232646594.29087.88.camel@lb-tlvb-eliezer>
References: <1232517051.9701.26.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: "Harvey Harrison" <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3279 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760195AbZAVRvB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 12:51:01 -0500
In-Reply-To: <1232517051.9701.26.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-20 at 21:50 -0800, Harvey Harrison wrote:
> No functional annotations, just documenting the status quo.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

[...]

> @@ -9699,11 +9699,11 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  						 bd_prod, ++nbd);
>  
>  		pbd->lso_mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
> -		pbd->tcp_send_seq = swab32(tcp_hdr(skb)->seq);
> +		pbd->tcp_send_seq = cpu_to_le32(be32_to_cpu(tcp_hdr(skb)->seq));

Hmmm.... That looks worse to me. Do we really need to replace swab with
cpu_to_le on top of be_to_cpu?

>  		pbd->tcp_flags = pbd_tcp_flags(skb);
>  
>  		if (xmit_type & XMIT_GSO_V4) {
> -			pbd->ip_id = swab16(ip_hdr(skb)->id);
> +			pbd->ip_id = cpu_to_le16(be16_to_cpu(ip_hdr(skb)->id));

Same question

>  			pbd->tcp_pseudo_csum =
>  				swab16(~csum_tcpudp_magic(ip_hdr(skb)->saddr,
>  							  ip_hdr(skb)->daddr,


