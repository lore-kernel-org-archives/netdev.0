From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [RFC 1/2] net-next: add a dma_desc element to struct
 skb_shared_info
Date: Fri, 21 Jul 2017 17:56:39 +0200
Message-ID: <1500652599.3924.10.camel@redhat.com>
References: <20170721152035.6645-1-john@phrozen.org>
         <20170721152035.6645-2-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>,
        "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170721152035.6645-2-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, 2017-07-21 at 17:20 +0200, John Crispin wrote:
> In order to make HW flow offloading work in latest MediaTek silicon we need
> to propagate part of the RX DMS descriptor to the upper layers populating
> the flow offload engines HW tables. This patch adds an extra element to
> struct skb_shared_info allowing the ethernet drivers RX napi code to store
> the required information and make it persistent for the lifecycle of the
> skb and its clones.
> 
> Signed-off-by: John Crispin <john@phrozen.org>
> ---
>  include/linux/skbuff.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 4093552be1de..db9576cd946b 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -426,6 +426,7 @@ struct skb_shared_info {
>  	unsigned int	gso_type;
>  	u32		tskey;
>  	__be32          ip6_frag_id;
> +	u32		dma_desc;
>  
>  	/*
>  	 * Warning : all fields before dataref are cleared in __alloc_skb()

This will increase the skb_shared_info struct size, which is already
quite large, and can have several kind of performance drawback.
AFAIK this is discouraged. 

I don't understand the use case; the driver will set this field, but
who is going to consume it?

Thanks,

Paolo
