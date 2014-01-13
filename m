From: Cong Wang <cwang@twopensource.com>
Subject: Re: suspicious RCU usage in net/ipv4/ip_tunnel.c:80
Date: Mon, 13 Jan 2014 11:35:23 -0800
Message-ID: <CAHA+R7MC4gDzKagAJ2y_2Jyb=Jx-Xkb9ns3-kqYGxH4MH8945g@mail.gmail.com>
References: <CAHA+R7PAyR_cJ9_9nfUBc0U9o-U=gCV+sN_VYbHwgq-QdoEVzQ@mail.gmail.com>
	<1389403281.31367.171.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Tom Herbert <therbert@google.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:63180 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbaAMTfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:35:25 -0500
Received: by mail-la0-f49.google.com with SMTP id y1so1472115lam.22
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 11:35:23 -0800 (PST)
In-Reply-To: <1389403281.31367.171.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 5:21 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Please use following sparse ready patch, thanks :
>
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index d3929a69f008..6eda759b5c4b 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -77,10 +77,11 @@ static inline void __tunnel_dst_set(struct ip_tunnel_dst *idst,
>                 dst = NULL;
>
>         spin_lock_bh(&idst->lock);
> -       old_dst = rcu_dereference(idst->dst);
> +       old_dst = rcu_dereference_protected(idst->dst,
> +                                           lockdep_is_held(&idst->lock));
>         rcu_assign_pointer(idst->dst, dst);
> -       dst_release(old_dst);
>         spin_unlock_bh(&idst->lock);
> +       dst_release(old_dst);
>  }
>
>  static inline void tunnel_dst_set(struct ip_tunnel *t, struct dst_entry *dst)
>
>

Tested-by: Cong Wang <cwang@twopensource.com>
