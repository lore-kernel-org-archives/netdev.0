From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Networking: Core: netpoll: Fixed a missing spin_unlock
Date: Sat, 30 Jul 2016 23:58:36 +0200
Message-ID: <20160730215836.GA22500@electric-eye.fr.zoreil.com>
References: <1469840027-17057-1-git-send-email-salilkapur93@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Salil Kapur <salilkapur93@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1469840027-17057-1-git-send-email-salilkapur93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Salil Kapur <salilkapur93@gmail.com> :
[...]
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index fc75c9e..9124f76 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -386,8 +386,10 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
>  					    !vlan_hw_offload_capable(netif_skb_features(skb),
>  								     skb->vlan_proto)) {
>  						skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
> -						if (unlikely(!skb))
> +						if (unlikely(!skb)) {
> +							__netif_tx_unlock(txq);
>  							break;
> +						}
>  						skb->vlan_tci = 0;
>  					}
>  

Your kernel is outdated: __vlan_put_tag has disappeared from net/core/netpoll.c
since 62749e2cb3c4a7da3eaa5c01a7e787aebeff8536 ("vlan: rename __vlan_put_tag to
vlan_insert_tag_set_proto") by Jiri Pirko somewhere in 2014.

-- 
Ueimor
