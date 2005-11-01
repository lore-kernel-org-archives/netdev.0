From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH][MCAST]IPv6: small fix for ip6_mc_msfilter(...)
Date: Tue, 1 Nov 2005 15:55:05 -0800
Message-ID: <OF19AE07D9.BF2B28D4-ON882570AC.0083498D-882570AC.00835D3A@us.ibm.com>
References: <4367FF22.3030601@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751454AbVKAXy4@vger.kernel.org>
In-Reply-To: <4367FF22.3030601@21cn.com>
To: Yan Zheng <yanzheng@21cn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks good. Thanks, Yan.

                        +-DLS

Acked-by: David L Stevens <dlstevens@us.ibm.com>

> 
> Signed-off-by: Yan Zheng <yanzheng@21cn.com>
> 
> Patch for IPv4
> Index:net/ipv4/igmp.c
> ============================================================
> --- linux-2.6.14/net/ipv4/igmp.c   2005-10-28 08:02:08.000000000 +0800
> +++ linux/net/ipv4/igmp.c   2005-11-02 07:31:01.000000000 +0800
> @@ -1908,8 +1908,11 @@ int ip_mc_msfilter(struct sock *sk, stru
>          sock_kfree_s(sk, newpsl, IP_SFLSIZE(newpsl->sl_max));
>          goto done;
>       }
> -   } else
> +   } else {
>       newpsl = NULL;
> +      (void) ip_mc_add_src(in_dev, &msf->imsf_multiaddr,
> +         msf->imsf_fmode, 0, NULL, 0)
> +   }
>    psl = pmc->sflist;
>    if (psl) {
>       (void) ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
> 
> 
> 
> 
> Patch for IPv6
> Index:net/ipv6/mcast.c
> ============================================================
> --- linux-2.6.14/net/ipv6/mcast.c   2005-10-30 23:09:33.000000000 +0800
> +++ linux/net/ipv6/mcast.c   2005-11-02 07:19:12.000000000 +0800
> @@ -545,8 +545,10 @@ int ip6_mc_msfilter(struct sock *sk, str
>          sock_kfree_s(sk, newpsl, IP6_SFLSIZE(newpsl->sl_max));
>          goto done;
>       }
> -   } else
> +   } else {
>       newpsl = NULL;
> +      (void) ip6_mc_add_src(idev, group, gsf->gf_fmode, 0, NULL, 0);
> +   }
>    psl = pmc->sflist;
>    if (psl) {
>       (void) ip6_mc_del_src(idev, group, pmc->sfmode,
> 
> 
