From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2 nf-next 3/6] netfilter: bridge: use skb->cb to track
 otherhost mangling
Date: Thu, 12 Mar 2015 19:02:00 +0100
Message-ID: <5501D498.4050003@hartkopp.net>
References: <1426179925-18220-1-git-send-email-fw@strlen.de> <1426179925-18220-4-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eyal Birger <eyal.birger@gmail.com>
To: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1426179925-18220-4-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 03/12/2015 06:05 PM, Florian Westphal wrote:
> nf_bridge_info->mask is used for several things, for example to remember
> if skb->pkt_type was set to OTHER_HOST.
> 
> For a bridge, OTHER_HOST is expected case. For ip forward its a
> non-starter though -- routing expects PACKET_HOST.
> 
> Bridge netfilter thus changes OTHER_HOST to PACKET_HOST
> before hook invocation and then un-does it after hook traversal.
> 
> For this, cb[] can be used since the skb will never be used outside
> (fake inet) bridge forwarding while in 'fake PACKET_HOST' state.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  include/linux/netfilter_bridge.h |  1 -
>  net/bridge/br_netfilter.c        | 71 ++++++++++++++++++++++++++--------------


> @@ -1104,6 +1125,8 @@ static int __init br_netfilter_init(void)
>  {
>  	int ret;
>  
> +	BUILD_BUG_ON(sizeof(struct nf_bridge_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
> +

Please use sock_skb_cb_check_size(size) for cb size checking which is the
'new' check for cb sizes for netdev.

See:

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit?id=b4772ef879a8f7d8c56118c2ae5a296fcf6f81d2

>  	ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
>  	if (ret < 0)
>  		return ret;
> 

Regards,
Oliver
