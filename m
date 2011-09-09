From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG?] tcp: potential bug in tcp_is_sackblock_valid()
Date: Fri, 9 Sep 2011 11:54:29 +1000
Message-ID: <20110909015429.GA9156@gondor.apana.org.au>
References: <4E696FD0.7060702@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51386 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932067Ab1IIBye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 21:54:34 -0400
Content-Disposition: inline
In-Reply-To: <4E696FD0.7060702@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 09, 2011 at 09:45:52AM +0800, Yan, Zheng wrote:
> Hi all,
> 
> I found a check in tcp_is_sackblock_valid() is suspicious. It against
> its comment and RFC. I think the correct check should be:
> 
> ---
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 385c470..a5d01b1 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1124,7 +1124,7 @@ static int tcp_is_sackblock_valid(struct tcp_sock *tp, int is_dsack,
>                 return 0;
>  
>         /* ...Then it's D-SACK, and must reside below snd_una completely */
> -       if (!after(end_seq, tp->snd_una))
> +       if (after(end_seq, tp->snd_una))
>                 return 0;
>  
>         if (!before(start_seq, tp->undo_marker))
> ---
> 
> I also checked /proc/net/netstat of my laptop, found TCPDSACKIgnoredOld
> field is not zero. Maybe it's caused by the bug.

Yes this looks like a typo.  Please resend your patch with a
description and signed-off-by line.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
