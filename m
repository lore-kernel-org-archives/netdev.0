From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net-next] rtnl: fix the loop index update error in
 rtnl_dump_ifinfo()
Date: Sat, 19 Nov 2016 21:45:38 -0500
Message-ID: <713e95b3-8a90-1ef5-70af-dcc5426b2884@cumulusnetworks.com>
References: <1479569312-15224-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:35041 "EHLO
        mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753004AbcKTCpj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 21:45:39 -0500
Received: by mail-ua0-f181.google.com with SMTP id 12so201272807uas.2
        for <netdev@vger.kernel.org>; Sat, 19 Nov 2016 18:45:39 -0800 (PST)
In-Reply-To: <1479569312-15224-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/16 10:28 AM, Zhang Shengju wrote:
> If the link is filtered out, loop index should also be updated. If not,
> loop index will not be correct.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  net/core/rtnetlink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index db313ec..f4b9350 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1606,7 +1606,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
>  		head = &net->dev_index_head[h];
>  		hlist_for_each_entry(dev, head, index_hlist) {
>  			if (link_dump_filtered(dev, master_idx, kind_ops))
> -				continue;
> +				goto cont;
>  			if (idx < s_idx)
>  				goto cont;
>  			err = rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
> 

Fixes: dc599f76c22b0 ("net: Add support for filtering link dump by master device and kind")

Acked-by: David Ahern <dsa@cumulusnetworks.com>
