From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen
Date: Thu, 30 Nov 2006 09:33:43 -0800
Message-ID: <456F15F7.3000700@candelatech.com>
References: <20061121212251.GA5084@martell.zuzino.mipt.ru>	<20061128.153325.10304536.davem@davemloft.net>	<20061129200437.GA5152@martell.zuzino.mipt.ru>	<20061129.174943.112291690.davem@davemloft.net>	<b6fcc0a0611292330n42fb1485h59804cc94a332f19@mail.gmail.com> <17774.39482.949953.625608@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	David Miller <davem@davemloft.net>, pavol.gono@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:40867 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1030876AbWK3RcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 12:32:21 -0500
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <17774.39482.949953.625608@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Hello!
>
> Seems you found a race when rmmod is done before it's fully started
>
> Try:
>
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 733d86d..ac0b4b1 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -160,7 +160,7 @@
>  #include <asm/div64.h>		/* do_div */
>  #include <asm/timex.h>
>  
> -#define VERSION  "pktgen v2.68: Packet Generator for packet performance testing.\n"
> +#define VERSION  "pktgen v2.69: Packet Generator for packet performance testing.\n"
>  
>  /* #define PG_DEBUG(a) a */
>  #define PG_DEBUG(a)
> @@ -3673,6 +3673,8 @@ static void __exit pg_cleanup(void)
>  	struct list_head *q, *n;
>  	wait_queue_head_t queue;
>  	init_waitqueue_head(&queue);
> +	
> +	schedule_timeout_interruptible(msecs_to_jiffies(125));
>  
>  	/* Stop all interfaces & threads */
>  
>   
That strikes me as a hack..surely there is a better method than just adding
a sleep??

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


