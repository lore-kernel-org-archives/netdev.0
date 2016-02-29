From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] mld, igmp: Fix reserved tailroom calculation
Date: Mon, 29 Feb 2016 19:28:30 +0100
Message-ID: <56D48DCE.3090705@stressinduktion.org>
References: <1456603028-12589-2-git-send-email-bpoirier@suse.com>
 <56D45C6A.5040606@iogearbox.net> <20160229151920.GA5474@f1.synalogic.ca>
 <56D4670C.40902@stressinduktion.org> <20160229180835.GA6224@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:52114 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752289AbcB2S2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 13:28:33 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id D0A4E2080D
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:32 -0500 (EST)
In-Reply-To: <20160229180835.GA6224@f1.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.02.2016 19:08, Benjamin Poirier wrote:
> If you think we should write the expression with "if" instead of "min",
> instead of the current
>
> +	skb->reserved_tailroom = skb_tailroom(skb) -
> +		min_t(int, mtu, skb_tailroom(skb) - tlen);
>
> it should be:
>
> +	if (mtu < skb_tailroom(skb) - tlen)
> +		skb->reserved_tailroom = skb_tailroom(skb) - mtu;
> +	else
> +		skb->reserved_tailroom = tlen;
>
> The second alternative does not look more readable to me but I have been
> looking at that expression for a while. If you think that it is more
> readable, I will resend the patch expressed that way. Please let me
> know.

I would still find it more readable actually, but no strong opinion, I 
would leave it up to you.

Could it make sense to put this code into a static inline helper and 
reuse it for both, igmp and mld?

Thanks,
Hannes
