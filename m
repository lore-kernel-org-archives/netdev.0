From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [net] rtnetlink: fix the wrong minimal dump size getting from
 rtnl_calcit()
Date: Wed, 23 Nov 2016 07:38:53 -0800
Message-ID: <5835B80D.80307@cumulusnetworks.com>
References: <1479795268-11801-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:32837 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965392AbcKWPjA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 10:39:00 -0500
Received: by mail-pf0-f179.google.com with SMTP id d2so4152595pfd.0
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 07:39:00 -0800 (PST)
In-Reply-To: <1479795268-11801-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/16, 10:14 PM, Zhang Shengju wrote:
> For RT netlink, calcit() function should return the minimal size for
> netlink dump message. This will make sure that dump message for every
> network device can be stored.
>
> Currently, rtnl_calcit() function doesn't account the size of header of
> netlink message, this patch will fix it.
>
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  net/core/rtnetlink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index f4b9350..09e115b 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2734,7 +2734,7 @@ static u16 rtnl_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
>  						           ext_filter_mask));
>  	}
>  
> -	return min_ifinfo_dump_size;
> +	return nlmsg_total_size(min_ifinfo_dump_size);
>  }
>  
>  static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)

This looks fine to me. However, looking at the git log, since this code has been
around for so long, it seems like it can go into net-next. But, that's just my 2c.
 
