From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] rtnetlink: Handle IFLA_MASTER parameter when processing
 rtnl_newlink
Date: Mon, 30 Jan 2017 14:44:54 -0800
Message-ID: <20170130144454.7ece3a73@xeon-e3>
References: <38fc316c-a522-a8ca-d029-25fa5335a954@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Theuns Verwoerd <Theuns.Verwoerd@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34345 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752347AbdA3WwT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 17:52:19 -0500
Received: by mail-pf0-f176.google.com with SMTP id e4so94229273pfg.1
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 14:51:23 -0800 (PST)
In-Reply-To: <38fc316c-a522-a8ca-d029-25fa5335a954@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jan 2017 22:28:05 +0000
Theuns Verwoerd <Theuns.Verwoerd@alliedtelesis.co.nz> wrote:

> rtnetlink: Handle IFLA_MASTER parameter when processing rtnl_newlink
> 
> Allow a master interface to be specified as one of the parameters when
> creating a new interface via rtnl_newlink.  Previously this would
> require invoking interface creation, waiting for it to complete, and
> then separately binding that new interface to a master.
> 
> In particular, this is used when creating a macvlan child interface for
> VRRP in a VRF configuration, allowing the interface creator to specify
> directly what master interface should be inherited by the child,
> without having to deal with asynchronous complications and potential
> race conditions.
> 
> Signed-off-by: Theuns Verwoerd <theuns.verwoerd@alliedtelesis.co.nz>
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 75e3ea7bda08..a24719c98238 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2571,7 +2571,7 @@ static int rtnl_newlink(struct sk_buff *skb, 
> struct nlmsghdr *nlh)
>                          return -ENODEV;
>                  }
> 
> -               if (tb[IFLA_MAP] || tb[IFLA_MASTER] || tb[IFLA_PROTINFO])
> +               if (tb[IFLA_MAP] || tb[IFLA_PROTINFO])
>                          return -EOPNOTSUPP;
> 
>                  if (!ops) {
> @@ -2653,6 +2653,11 @@ static int rtnl_newlink(struct sk_buff *skb, 
> struct nlmsghdr *nlh)
>                          if (err < 0)
>                                  goto out_unregister;
>                  }
> +               if (tb[IFLA_MASTER]) {
> +                       err = do_set_master(dev, 
> nla_get_u32(tb[IFLA_MASTER]));
> +                       if (err)
> +                               goto out_unregister;
> +               }
>   out:
>                  if (link_net)
>                          put_net(link_net);

Your mailer is reformatting text which corrupts patches.
Please adjust your client settings, or use a different mail system.
