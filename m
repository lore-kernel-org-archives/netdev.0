From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH RESEND] sctp: fix incorrect overflow check on autoclose
Date: Fri, 09 Dec 2011 12:38:19 -0500
Message-ID: <4EE2478B.5010409@hp.com>
References: <1323393883-3759-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrei Pelinescu-Onciul <andrei@iptel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:19177 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301Ab1LIRi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 12:38:26 -0500
In-Reply-To: <1323393883-3759-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2011 08:24 PM, Xi Wang wrote:
> The commit 8ffd3208 voids the previous patches f6778aab and 810c0719
> for limiting the maximum autoclose value.  If userspace passes in -1
> on 32-bit platform, the overflow check didn't work and autoclose
> would be set to 0xffffffff.
> 
> Signed-off-by: Xi Wang <xi.wang@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrei Pelinescu-Onciul <andrei@iptel.org>
> Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  net/sctp/socket.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 13bf5fc..bb91281 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -2201,7 +2201,8 @@ static int sctp_setsockopt_autoclose(struct sock *sk, char __user *optval,
>  	if (copy_from_user(&sp->autoclose, optval, optlen))
>  		return -EFAULT;
>  	/* make sure it won't exceed MAX_SCHEDULE_TIMEOUT */
> -	sp->autoclose = min_t(long, sp->autoclose, MAX_SCHEDULE_TIMEOUT / HZ);
> +	sp->autoclose = min_t(unsigned long, sp->autoclose,
> +			      MAX_SCHEDULE_TIMEOUT / HZ);

I think this should be u32 since that's what sp->autoclose is.

-vlad

>  
>  	return 0;
>  }
