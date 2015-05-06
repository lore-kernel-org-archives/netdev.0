From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 2/4] ip: return correct exit code on route failure
Date: Wed, 06 May 2015 10:19:45 -0700
Message-ID: <554A4D31.1080809@cumulusnetworks.com>
References: <1430931483-28595-1-git-send-email-stephen@networkplumber.org> <1430931483-28595-3-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemming@brocade.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34694 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbbEFRTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 13:19:46 -0400
Received: by pacyx8 with SMTP id yx8so15055244pac.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 10:19:46 -0700 (PDT)
In-Reply-To: <1430931483-28595-3-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/6/15, 9:58 AM, Stephen Hemminger wrote:
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
>      fix ip -force -batch to continue on errors
> ---
>   ip/iproute.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/ip/iproute.c b/ip/iproute.c
> index e0a6159..06aea6f 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -1164,7 +1164,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
>   		req.r.rtm_family = AF_INET;
>   
>   	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
> -		return -1;
> +		return -2;
>   
>   	return 0;
>   }
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Thanks for documenting the error code convention.
