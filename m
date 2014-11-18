From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] ipv6: delete protocol when cleanup
Date: Tue, 18 Nov 2014 10:56:40 -0800
Message-ID: <CAHA+R7PNmac7KQpSK-vO9zVd3+926f6n_GpaGrbpBnSn98xiyQ@mail.gmail.com>
References: <546B20F8.6010806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:38324 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884AbaKRS4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 13:56:42 -0500
Received: by mail-qg0-f41.google.com with SMTP id j5so3139613qga.0
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 10:56:42 -0800 (PST)
In-Reply-To: <546B20F8.6010806@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 2:35 AM, Duan Jiong <duanj.fnst@cn.fujitsu.com> wrote:
>
> pim6_protocol was added when initiation, but it not deleted.
>
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
>  net/ipv6/ip6mr.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
> index 0171f08..6dcdecd 100644
> --- a/net/ipv6/ip6mr.c
> +++ b/net/ipv6/ip6mr.c
> @@ -1439,6 +1439,9 @@ reg_pernet_fail:
>
>  void ip6_mr_cleanup(void)
>  {
> +#ifdef CONFIG_IPV6_PIMSM_V2
> +       inet6_del_protocol(&pim6_protocol, IPPROTO_PIM);
> +#endif
>         unregister_netdevice_notifier(&ip6_mr_notifier);
>         unregister_pernet_subsys(&ip6mr_net_ops);
>         kmem_cache_destroy(mrt_cachep);


Looks like rtnl_unregister() is missing as well.
