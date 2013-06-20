From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 5/8] vxlan: Factor out vxlan send api.
Date: Thu, 20 Jun 2013 08:46:42 -0400
Message-ID: <OF9BEEA27A.EA477839-ON87257B90.0045D6A5-85257B90.00463241@us.ibm.com>
References: <1371713207-8232-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1371713207-8232-1-git-send-email-pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
 

> @@ -1205,13 +1222,13 @@ static netdev_tx_t vxlan_xmit(struct sk_buff
> *skb, struct net_device *dev)
> 
>        skb1 = skb_clone(skb, GFP_ATOMIC);
>        if (skb1) {
> -         rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
> +         rc1 = __vxlan_xmit(skb1, dev, rdst, did_rsc);
>           if (rc == NETDEV_TX_OK)
>              rc = rc1;
>        }
>     }
> 
> -   rc1 = vxlan_xmit_one(skb, dev, rdst0, did_rsc);
> +   rc1 = __vxlan_xmit(skb, dev, rdst0, did_rsc);
>     if (rc == NETDEV_TX_OK)
>        rc = rc1;
>     return rc;

You're changing the name of the function that sends a
packet to one destination because you think "__vxlan_xmit"
is more descriptive than "vxlan_xmit_one" ?

                                                +-DLS
