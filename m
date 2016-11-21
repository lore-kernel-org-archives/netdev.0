From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH net-next 1/1] driver: macvlan: Remove duplicated IFF_UP
 condition check in macvlan_forward_source
Date: Mon, 21 Nov 2016 08:52:45 +0800
Message-ID: <CA+6hz4pFLqs_BgUvkbf3B5dG3yR=8QTLgVZjyTm2oaaPN=QOZg@mail.gmail.com>
References: <1479687998-456-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "David S. Miller" <davem@davemloft.net>,
        Patrick McHardy <kaber@trash.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Feng Gao <gfree.wind@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:34397 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbcKUAwq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 19:52:46 -0500
Received: by mail-vk0-f65.google.com with SMTP id p9so22882214vkd.1
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 16:52:46 -0800 (PST)
In-Reply-To: <1479687998-456-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2016 at 8:26 AM,  <fgao@ikuai8.com> wrote:
> From: Gao Feng <gfree.wind@gmail.com>
>
> The function macvlan_forward_source_one has already checked the flag
> IFF_UP, so needn't check it outside in macvlan_forward_source too.
>
> Signed-off-by: Gao Feng <gfree.wind@gmail.com>
> ---
>  v2: Remove the IFF_UP check in macvlan_forward_source instead of macvlan_forward_source_one
>  v1: Initial patch
>
>  drivers/net/macvlan.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 13b7e0b..7ddfd2c 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -400,8 +400,7 @@ static void macvlan_forward_source(struct sk_buff *skb,
>
>         hlist_for_each_entry_rcu(entry, h, hlist) {
>                 if (ether_addr_equal_64bits(entry->addr, addr))
> -                       if (entry->vlan->dev->flags & IFF_UP)
> -                               macvlan_forward_source_one(skb, entry->vlan);
> +                       macvlan_forward_source_one(skb, entry->vlan);
>         }
>  }
>
> --
> 1.9.1
>
>

Sorry, I forget add the "v2" in the title.

Regards
Feng
