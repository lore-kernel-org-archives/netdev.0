From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 10/10] net: Allow tunnels to use inner checksum
 offloads with outer checksums needed
Date: Sat, 6 Feb 2016 13:00:07 -0800
Message-ID: <CALx6S37xA7c_BA4h-AzeFF+Q2XdKnJG5veuoiNYrLzScRe6Y=w@mail.gmail.com>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
	<20160205232826.18529.69333.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Edward Cree <ecree@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35779 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723AbcBFVAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 16:00:07 -0500
Received: by mail-ig0-f182.google.com with SMTP id hb3so34770074igb.0
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 13:00:07 -0800 (PST)
In-Reply-To: <20160205232826.18529.69333.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 5, 2016 at 3:28 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch enables us to use inner checksum offloads if provided by
> hardware with outer checksums computed by software.
>
> It basically reduces encap_hdr_csum to an advisory flag for now, but based
> on the fact that SCTP may be getting segmentation support before long I
> thought we may want to keep it as it is possible we may need to support
> CRC32c and 1's compliment checksum in the same packet at some point in the
> future.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Acked-by: Tom Herbert <tom@herbertland.com>

> ---
>  net/core/skbuff.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 88262c82b96a..b0cce744e2a0 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3004,8 +3004,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>         if (unlikely(!proto))
>                 return ERR_PTR(-EINVAL);
>
> -       csum = !head_skb->encap_hdr_csum &&
> -           !!can_checksum_protocol(features, proto);
> +       csum = !!can_checksum_protocol(features, proto);
>
>         headroom = skb_headroom(head_skb);
>         pos = skb_headlen(head_skb);
>
