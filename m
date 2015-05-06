From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH 2/4] ip: return correct exit code on route failure
Date: Wed, 6 May 2015 20:25:02 +0300
Message-ID: <20150506172502.GA2560@angus-think.lan>
References: <1430931483-28595-1-git-send-email-stephen@networkplumber.org>
 <1430931483-28595-3-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemming@brocade.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:34359 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbEFRZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 13:25:33 -0400
Received: by wicmx19 with SMTP id mx19so130320610wic.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 10:25:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430931483-28595-3-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 06, 2015 at 09:58:01AM -0700, Stephen Hemminger wrote:
> From: Stephen Hemminger <shemming@brocade.com>
> 
> If kernel complains about ip route request, exit status should be
> 2 not 1.
> 
> This fixes regression introduced by:
> commit 42ecedd4bae534fc688194a795eb4548c6530cda
> Author: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date:   Tue Mar 17 19:26:32 2015 -0700
> 
>     fix ip -force -batch to continue on errors
> ---
>  ip/iproute.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/ip/iproute.c b/ip/iproute.c
> index e0a6159..06aea6f 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -1164,7 +1164,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
>  		req.r.rtm_family = AF_INET;
>  
>  	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
> -		return -1;
> +		return -2;
May be it would be good to have a #define's like ERR_APP & ERR_KERN ?

>  
>  	return 0;
>  }
> -- 
> 2.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
