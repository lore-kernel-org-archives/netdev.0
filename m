From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH][net-next] netpoll: slight optimization for netpoll_neigh_reply
Date: Tue, 18 Mar 2014 08:05:50 +0800
Message-ID: <CAJFZqHwTCyN+u+h+u2sPHCPLE4q_YNTfg1q7akvPu1ZV0_i0gg@mail.gmail.com>
References: <1395040188-24840-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:43301 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbaCRAFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 20:05:51 -0400
Received: by mail-qc0-f181.google.com with SMTP id e9so6976815qcy.12
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 17:05:50 -0700 (PDT)
In-Reply-To: <1395040188-24840-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this patch can be dropped since other patch has been merged into
net-next[netpoll: Remove dead packet receive code
(CONFIG_NETPOLL_TRAP)]

On Mon, Mar 17, 2014 at 3:09 PM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> 'hits' is used to check If there is a device who is interested
> in this skb, not care the device number, so stop the loop once
> a device is found
>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/core/netpoll.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index dd0a796..9a276e6 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -545,8 +545,10 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
>            inspection whether this is interesting at all */
>         spin_lock_irqsave(&npinfo->rx_lock, flags);
>         list_for_each_entry_safe(np, tmp, &npinfo->rx_np, rx) {
> -               if (np->dev == skb->dev)
> +               if (np->dev == skb->dev) {
>                         hits++;
> +                       break;
> +               }
>         }
>         spin_unlock_irqrestore(&npinfo->rx_lock, flags);
>
> --
> 1.7.10.4
>
