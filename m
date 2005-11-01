From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH][MCAST]IPv6: small fix for ip6_mc_msfilter(...)
Date: Tue, 1 Nov 2005 13:27:36 -0800
Message-ID: <OF395F8772.5B834BF9-ON882570AC.0075ACD7-882570AC.0075DC3C@us.ibm.com>
References: <436586F0.9080101@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751262AbVKAV1a@vger.kernel.org>
In-Reply-To: <436586F0.9080101@21cn.com>
To: Yan Zheng <yanzheng@21cn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yan,
        Please also make this equivalent change in IPv4 with
ip_mc_msfilter() and ip_mc_add_src().

                                                +-DLS

Acked-by: David L Stevens <dlstevens@us.ibm.com> 
> 
> Signed-off-by: Yan Zheng <yanzheng@21cn.com> 
> 
> Index: net/ipv6/mcast.c
> 
================================================================================
> --- linux-2.6.14/net/ipv6/mcast.c   2005-10-30 23:09:33.000000000 +0800
> +++ linux/net/ipv6/mcast.c   2005-10-31 10:37:36.000000000 +0800
> @@ -545,8 +545,10 @@ int ip6_mc_msfilter(struct sock *sk, str
>           sock_kfree_s(sk, newpsl, IP6_SFLSIZE(newpsl->sl_max));
>           goto done;
>        }
> -   } else
> +   } else {
>        newpsl = NULL;
> +      ip6_mc_add_src(idev, group, gsf->gf_fmode, 0, NULL, 0);
> +   }
>     psl = pmc->sflist;
>     if (psl) {
>        (void) ip6_mc_del_src(idev, group, pmc->sfmode,
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
