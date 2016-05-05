From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 14/14] ip4ip6: Support for GSO/GRO
Date: Wed, 04 May 2016 18:20:29 -0700
Message-ID: <1462411229.13075.13.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
	 <1462410164-1953217-15-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36662 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755531AbcEEBUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 21:20:32 -0400
Received: by mail-pf0-f182.google.com with SMTP id c189so32501640pfb.3
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 18:20:32 -0700 (PDT)
In-Reply-To: <1462410164-1953217-15-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-04 at 18:02 -0700, Tom Herbert wrote:
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 928b456..6a811fa 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -484,6 +484,8 @@ enum {
>  	SKB_GSO_TUNNEL_REMCSUM = 1 << 14,
>  
>  	SKB_GSO_IP6IP6 = 1 << 15,
> +
> +	SKB_GSO_IP4IP6 = 1 << 16,
>  };
>  

Houston, we have a problem.

gso_type is 16bit (unsigned short), or maybe I missed something ?

struct skb_shared_info {
	unsigned char	nr_frags;
	__u8		tx_flags;
	unsigned short	gso_size;
	unsigned short	gso_segs;
	unsigned short  gso_type; <<-->>
