From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] ip_tunnel(ipv4): fix tunnels with "local any remote $remote_ip"
Date: Mon, 28 Jul 2014 16:39:23 -0700
Message-ID: <CAHA+R7P3gN6Xd==bF9r=396DBi=sTab7tHgZr4agiLxDBdrk+g@mail.gmail.com>
References: <20140729030752.d156e9522754e8a6262541ec@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Sergey Popov <pinkbyte@gentoo.org>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>
To: Dmitry Popov <ixaphire@qrator.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:53039 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbaG1XjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 19:39:25 -0400
Received: by mail-la0-f44.google.com with SMTP id e16so6000491lan.17
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 16:39:23 -0700 (PDT)
In-Reply-To: <20140729030752.d156e9522754e8a6262541ec@qrator.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 28, 2014 at 4:07 PM, Dmitry Popov <ixaphire@qrator.net> wrote:
> --- a/include/net/ip_tunnels.h
> +++ b/include/net/ip_tunnels.h
> @@ -40,6 +40,7 @@ struct ip_tunnel_prl_entry {
>
>  struct ip_tunnel_dst {
>         struct dst_entry __rcu          *dst;
> +       __be32                           saddr;
>  };


It looks odd to save a source address in some struct named dst,
maybe it's the time to rename it.


>         if (dst) {
> -               if (dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
> +               if (!dst->obsolete || dst->ops->check(dst, cookie)) {
> +                       *saddr = idst->saddr;
> +               } else {

I am wondering if this always works, that is, if saddr could be still valid
as long as dst is valid?
