From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [v2 PATCH] net: Stop decapitating clones that have a head_frag
Date: Thu, 03 May 2012 06:33:58 +0200
Message-ID: <1336019638.12425.16.camel@edumazet-glaptop>
References: <20120503041842.8315.16138.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:51350 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab2ECEeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 00:34:04 -0400
Received: by wgbdr13 with SMTP id dr13so1344929wgb.1
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 21:34:03 -0700 (PDT)
In-Reply-To: <20120503041842.8315.16138.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 21:18 -0700, Alexander Duyck wrote:
> This change is meant ot prevent stealing the skb->head to use as a page in
> the event that the skb->head was cloned.  This allows the other clones to
> track each other via shinfo->dataref.
> 
> Without this we break down to two methods for tracking the reference count,
> one being dataref, the other being the page count.  As a result it becomes
> difficult to track how many references there are to skb->head.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  net/core/skbuff.c    |    9 +++++----
>  net/ipv4/tcp_input.c |    9 ++-------
>  2 files changed, 7 insertions(+), 11 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 52ba2b5..9e8caa0 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1699,17 +1699,18 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
>  			      struct splice_pipe_desc *spd, struct sock *sk)
>  {
>  	int seg;
> -	bool head_is_linear = !skb->head_frag;
> +	bool head_is_locked = !skb->head_frag || skb_cloned(skb);
>  

Thanks

Acked-by: Eric Dumazet <edumazet@google.com>
