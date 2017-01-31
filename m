From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] rtnetlink: Handle IFLA_MASTER parameter when processing rtnl_newlink
Date: Mon, 30 Jan 2017 22:49:36 -0800
Message-ID: <CAM_iQpW1+UK+ykB3s-yqi+ozR-BuRTvQ6hX1XmkMvAXSWEgkrg@mail.gmail.com>
References: <20170130232346.29761-1-theuns.verwoerd@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Theuns Verwoerd <theuns.verwoerd@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36797 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750764AbdAaGt6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 01:49:58 -0500
Received: by mail-wm0-f65.google.com with SMTP id r18so10471044wmd.3
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 22:49:58 -0800 (PST)
In-Reply-To: <20170130232346.29761-1-theuns.verwoerd@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 3:23 PM, Theuns Verwoerd
<theuns.verwoerd@alliedtelesis.co.nz> wrote:
> @@ -2653,6 +2653,11 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
>                         if (err < 0)
>                                 goto out_unregister;
>                 }
> +               if (tb[IFLA_MASTER]) {
> +                       err = do_set_master(dev, nla_get_u32(tb[IFLA_MASTER]));
> +                       if (err)
> +                               goto out_unregister;
> +               }
>  out:
>                 if (link_net)
>                         put_net(link_net);

Not sure if it is too late to call do_set_master() after
dev_change_net_namespace().
