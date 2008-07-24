From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Thu, 24 Jul 2008 20:46:30 +0800
Message-ID: <E1KM0DG-0001vY-00@gondolin.me.apana.org.au>
References: <1216850464-30000-2-git-send-email-opurdila@ixiacom.com>
Cc: netdev@vger.kernel.org, opurdila@ixiacom.com
To: opurdila@ixiacom.com (Octavian Purdila)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56154 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751950AbYGXMqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 08:46:33 -0400
In-Reply-To: <1216850464-30000-2-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila <opurdila@ixiacom.com> wrote:
> This patch introduces per skb control messages that can be used to
> directly exchange information between the application and the
> hardware, at a per packet level. Examples of usecases are: RX/TX
> hardware timestamps, TX scheduling (request hardware to send packets
> at a future time).

Putting it in the share info area makes its life-cycle management
difficult.  This is also a major change to how we store skb control
data.

> @@ -567,6 +612,8 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>        skb_shinfo(new)->gso_size = skb_shinfo(old)->gso_size;
>        skb_shinfo(new)->gso_segs = skb_shinfo(old)->gso_segs;
>        skb_shinfo(new)->gso_type = skb_shinfo(old)->gso_type;
> +
> +       skb_shinfo(new)->cmsg = skb_shinfo(old)->cmsg;
> }
> 
> /**
> @@ -610,7 +657,8 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
>                BUG();
> 
>        copy_skb_header(n, skb);
> -       return n;
> +
> +       return skb_cmsg_copy(n, gfp_mask);

What about the other callers of copy_skb_header, like pskb_copy?
In fact why isn't this in copy_skb_header?

Also what about pskb_expand_head?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
