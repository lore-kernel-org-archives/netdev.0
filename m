From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] [SCTP] Fix a type cast bug
Date: Fri, 16 May 2008 08:48:38 -0400
Message-ID: <482D82A6.1060704@hp.com>
References: <482D4A8E.4090903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:41710 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755212AbYEPMsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 08:48:42 -0400
In-Reply-To: <482D4A8E.4090903@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gui

Gui Jianfeng wrote:
> Vlad,
> 
> event_arg can never be the type of "struct sctp_chunk *" 
> if the event_type is SCTP_EVENT_T_OTHER. This fix
> prevents from potential kernel crash by some misuse.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
> ---
>  net/sctp/sm_sideeffect.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index a4763fd..1b4bae9 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -1072,7 +1072,8 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>  	struct sctp_sackhdr sackh;
>  	int local_cork = 0;
>  
> -	if (SCTP_EVENT_T_TIMEOUT != event_type)
> +	if (SCTP_EVENT_T_TIMEOUT != event_type &&
> +	    SCTP_EVENT_T_OTHER != event_type)
>  		chunk = (struct sctp_chunk *) event_arg;
>  
>  	/* Note:  This whole file is a huge candidate for rework.


This doesn't really fix the bug since the event_arg can be something else during
primitive events and you would still have a typecast issue.

This code is rather ugly, but if we are going to clean it up, we need to do right
and not band-aid to death.

As it is, NACK on this patch, since it doesn't solve the problem.

-vlad

