From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: udp failures traced to e858fae2b0b8
Date: Mon, 13 Jun 2016 13:56:05 -0600
Message-ID: <973d7528-2ea7-47e3-cf19-208c24d85dec@cumulusnetworks.com>
References: <84272f6d-8c68-6b84-7f0a-6ef4ad8b9e03@cumulusnetworks.com>
 <20160613064202.GA14048@rapoport-lnx>
 <2ba80fe2-8274-33e2-afef-70170f31002c@cumulusnetworks.com>
 <20160613184040.GC14048@rapoport-lnx>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33566 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932757AbcFMT4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 15:56:08 -0400
Received: by mail-pf0-f176.google.com with SMTP id y124so49289583pfy.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 12:56:07 -0700 (PDT)
In-Reply-To: <20160613184040.GC14048@rapoport-lnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/13/16 12:40 PM, Mike Rapoport wrote:
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 9af0a98..9f8be96 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -482,10 +482,6 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
>  	if (hdr->hdr.flags & VIRTIO_NET_HDR_F_DATA_VALID)
>  		skb->ip_summed = CHECKSUM_UNNECESSARY;
>
> -	skb->protocol = eth_type_trans(skb, dev);
> -	pr_debug("Receiving skb proto 0x%04x len %i type %i\n",
> -		 ntohs(skb->protocol), skb->len, skb->pkt_type);
> -
>  	if (virtio_net_hdr_to_skb(skb, &hdr->hdr,
>  				  virtio_is_little_endian(vi->vdev))) {
>  		net_warn_ratelimited("%s: bad gso: type: %u, size: %u\n",
> @@ -494,6 +490,10 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
>  		goto frame_err;
>  	}
>
> +	skb->protocol = eth_type_trans(skb, dev);
> +	pr_debug("Receiving skb proto 0x%04x len %i type %i\n",
> +		 ntohs(skb->protocol), skb->len, skb->pkt_type);
> +
>  	napi_gro_receive(&rq->napi, skb);
>  	return;
>
>

Fixes the problem.
