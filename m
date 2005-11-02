From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH][MCAST]IPv6: small fix for ip6_mc_msfilter(...)
Date: Wed, 2 Nov 2005 19:55:50 -0200
Message-ID: <39e6f6c70511021355i52aff7e4n19ca4c1e24b21bb7@mail.gmail.com>
References: <OF395F8772.5B834BF9-ON882570AC.0075ACD7-882570AC.0075DC3C@us.ibm.com>
	 <4367FF22.3030601@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965278AbVKBVzw@vger.kernel.org>
To: Yan Zheng <yanzheng@21cn.com>
In-Reply-To: <4367FF22.3030601@21cn.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/1/05, Yan Zheng <yanzheng@21cn.com> wrote:
> David Stevens wrote:
> > Yan,
> >         Please also make this equivalent change in IPv4 with
> > ip_mc_msfilter() and ip_mc_add_src().
> >
> >                                                 +-DLS
> >
> > Acked-by: David L Stevens <dlstevens@us.ibm.com>
>
> To keep code style, I also create a new patch for IPv6. :-)
>
> Signed-off-by: Yan Zheng <yanzheng@21cn.com>
>
> Patch for IPv4
> Index:net/ipv4/igmp.c
> ============================================================
> --- linux-2.6.14/net/ipv4/igmp.c        2005-10-28 08:02:08.000000000 +0800
> +++ linux/net/ipv4/igmp.c       2005-11-02 07:31:01.000000000 +0800
> @@ -1908,8 +1908,11 @@ int ip_mc_msfilter(struct sock *sk, stru
>                         sock_kfree_s(sk, newpsl, IP_SFLSIZE(newpsl->sl_max));
>                         goto done;
>                 }
> -       } else
> +       } else {
>                 newpsl = NULL;
> +               (void) ip_mc_add_src(in_dev, &msf->imsf_multiaddr,
> +                       msf->imsf_fmode, 0, NULL, 0)

Could you please compile test it next time :-) hint, missing ';'.
Anyway, fixed up by hand.

- Arnaldo
