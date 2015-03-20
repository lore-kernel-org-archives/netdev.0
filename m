From: subashab@codeaurora.org
Subject: Re: [PATCH] net: rps: fix data stall after hotplug
Date: Fri, 20 Mar 2015 16:40:15 -0000
Message-ID: <b25a45de2cb43bbcfcaa84634d74533e.squirrel@www.codeaurora.org>
References: <b3ecb218932daa656a796cfa6e9e62b9.squirrel@www.codeaurora.org>
    <1426801839.25985.15.camel@edumazet-glaptop2.roam.corp.google.com>
    <1426852239.25985.33.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53389 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbbCTQkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 12:40:16 -0400
In-Reply-To: <1426852239.25985.33.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, 2015-03-19 at 14:50 -0700, Eric Dumazet wrote:
>
>> Are you seeing this race on x86 ?
>>
>> If IPI are not reliable on your arch, I am guessing you should fix them.
>>
>> Otherwise, even without hotplug you'll have hangs.
>
> Please try instead this patch :
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index
> 5d43e010ef870a6ab92895297fe18d6e6a03593a..baa4bff9a6fbe0d77d7921865c038060cb5efffd
> 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4320,9 +4320,8 @@ static void net_rps_action_and_irq_enable(struct
> softnet_data *sd)
>  		while (remsd) {
>  			struct softnet_data *next = remsd->rps_ipi_next;
>
> -			if (cpu_online(remsd->cpu))
> -				smp_call_function_single_async(remsd->cpu,
> -							   &remsd->csd);
> +			smp_call_function_single_async(remsd->cpu,
> +						       &remsd->csd);
>  			remsd = next;
>  		}
>  	} else
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
Thanks for the patch Eric. We are seeing this race on ARM.
I will try this and update.

--
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
 a Linux Foundation Collaborative Project
