From: "devendra.aaru" <devendra.aaru@gmail.com>
Subject: Re: [PATCH] bridge: fix endian
Date: Tue, 10 Jul 2012 15:34:38 +0530
Message-ID: <CAHdPZaP-eokSqBPWdxBg7fA-ETqvo0ivqG67KyJr3s6qb1xKBA@mail.gmail.com>
References: <1341914172-22075-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:46618 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608Ab2GJKEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 06:04:39 -0400
Received: by vbbff1 with SMTP id ff1so7914925vbb.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 03:04:38 -0700 (PDT)
In-Reply-To: <1341914172-22075-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As you are doing the same change to the drivers in drivers/net/*** i
think a patchset would be better.

but that's just upto you. ;-)

Thanks,

On Tue, Jul 10, 2012 at 3:26 PM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> mld->mld_maxdelay is net endian, so we should use ntohs, not htons
>
> CC: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/bridge/br_multicast.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index b665812..2d9a066 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1160,7 +1160,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
>                         goto out;
>                 }
>                 mld = (struct mld_msg *) icmp6_hdr(skb);
> -               max_delay = msecs_to_jiffies(htons(mld->mld_maxdelay));
> +               max_delay = msecs_to_jiffies(ntohs(mld->mld_maxdelay));
>                 if (max_delay)
>                         group = &mld->mld_mca;
>         } else if (skb->len >= sizeof(*mld2q)) {
> --
> 1.7.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
