From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/1] net: sock: Use USEC_PER_SEC macro instead
 of literal 1000000
Date: Mon, 20 Feb 2017 23:13:34 -0800
Message-ID: <1487661214.2853.14.camel@perches.com>
References: <1487601224-22241-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: fgao@ikuai8.com, davem@davemloft.net, edumazet@google.com,
        soheil@google.com, netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0111.hostedemail.com ([216.40.44.111]:52841 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751041AbdBUHNi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 02:13:38 -0500
In-Reply-To: <1487601224-22241-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-20 at 22:33 +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> The USEC_PER_SEC is used once in sock_set_timeout as the max value of
> tv_usec. But there are other similar codes which use the literal
> 1000000 in this file.
> It is minor cleanup to keep consitent.
[]
> diff --git a/net/core/sock.c b/net/core/sock.c
[]
> @@ -367,7 +367,7 @@ static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
>  	if (tv.tv_sec == 0 && tv.tv_usec == 0)
>  		return 0;
>  	if (tv.tv_sec < (MAX_SCHEDULE_TIMEOUT/HZ - 1))
> -		*timeo_p = tv.tv_sec*HZ + (tv.tv_usec+(1000000/HZ-1))/(1000000/HZ);
> +		*timeo_p = tv.tv_sec * HZ + (tv.tv_usec + (USEC_PER_SEC / HZ - 1)) / (USEC_PER_SEC / HZ);

Maybe convert this to DIV_ROUND_UP one day too?

	*timeo_p = tv.tv_sec * HZ + DIV_ROUND_UP(tv.tv_usec, USEC_PER_SEC / HZ);
