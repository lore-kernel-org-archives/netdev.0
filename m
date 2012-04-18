From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] set fake_rtable's dst to NULL to avoid kernel Oops.
Date: Wed, 18 Apr 2012 11:48:41 +0200
Message-ID: <1334742521.2472.102.camel@edumazet-glaptop>
References: <4F8E8A8F.30901@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	ctrix+debianbugs@navynet.it, peter.huangpeng@gmail.com,
	harry.majun@huawei.com, linux-kernel@vger.kernel.org
To: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54704 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751968Ab2DRJz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 05:55:26 -0400
In-Reply-To: <4F8E8A8F.30901@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-18 at 17:34 +0800, Peter Huang(Peng) wrote:
> Add new flag DST_FAKE_RTABLE to dst_entry struct.
> 

Your changelog is not very helpful. Please add all the information you
provided in your previous mails. (stack trace and all)

> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Peter Huang <peter.huangpeng@huawei.com>
> ---
>   include/linux/netfilter_bridge.h |    8 ++++++++
>   include/net/dst.h                |    1 +
>   net/bridge/br_forward.c          |    1 +
>   net/bridge/br_netfilter.c        |    8 ++------
>   4 files changed, 12 insertions(+), 6 deletions(-)
> diff --git a/include/linux/netfilter_bridge.h 
> b/include/linux/netfilter_bridge.h
> index 0ddd161..eb09e3b 100644
> --- a/include/linux/netfilter_bridge.h
> +++ b/include/linux/netfilter_bridge.h
> @@ -104,9 +104,17 @@ struct bridge_skb_cb {
>          } daddr;
>   };
> 
> +static inline void br_drop_fake_rtable(struct sk_buff *skb) {
> +       struct dst_entry *dst = skb_dst(skb);
> +       /* abuse fact that only fake_rtable has DST_FAKE_RTABLE set */

You are kidding ? I said "Remove this comment, and leave an empty line"

> +       if (dst && (dst->flags & DST_FAKE_RTABLE))
> +               skb_dst_drop(skb);
> +}

Patch mangled, tabulations were replaced by spaces.

Please, please please read again Documentation/email-clients.txt, as I
already mentioned (privately)

Double check _everything_ before your next submission

This is the last time I even care

Thanks
