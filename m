From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net-ipv4-tcp.c-fix-warning-from-older-compilers.patch
Date: Thu, 10 Dec 2009 14:31:56 +0000
Message-ID: <1260455516.2783.0.camel@achroite.uk.solarflarecom.com>
References: <200912090045.nB90jTaO010647@imap1.linux-foundation.org>
	 <4B1F0151.10903@gmail.com>
	 <20091208180801.88be28ba.akpm@linux-foundation.org>
	 <4B20FC2E.7050809@gmail.com>  <4B2102B4.7050702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:22080 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbZLJOb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 09:31:57 -0500
In-Reply-To: <4B2102B4.7050702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-12-10 at 09:16 -0500, William Allen Simpson wrote:
> Replace + net-ipv4-tcpc-fix-warning.patch added to -mm tree
> 
> Remove the offending code, and replace with comments.  This is an
> unlikely problem, so depend on human finding any future error.
> 
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>   net/ipv4/tcp.c |    9 ++++-----
>   1 files changed, 4 insertions(+), 5 deletions(-)
> plain text document attachment
> (net-ipv4-tcp.c-fix-warning-from-older-compilers.patch)
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index c8666b7..3782c17 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2540,11 +2540,10 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
>  			ctd.tcpct_cookie_desired = cvp->cookie_desired;
>  			ctd.tcpct_s_data_desired = cvp->s_data_desired;
>  
> -			/* Cookie(s) saved, return as nonce */
> -			if (sizeof(ctd.tcpct_value) < cvp->cookie_pair_size) {
> -				/* impossible? */
> -				return -EINVAL;
> -			}
> +			/* Cookie(s) saved, return as nonce.
> +			 * Assumes TCP_MSS_DEFAULT > TCP_COOKIE_PAIR_SIZE,
[...]

You can use BUILD_BUG_ON() to ensure that remains true.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

