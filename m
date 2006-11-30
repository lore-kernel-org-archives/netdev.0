From: David Miller <davem@davemloft.net>
Subject: Re: pktgen
Date: Wed, 29 Nov 2006 17:49:43 -0800 (PST)
Message-ID: <20061129.174943.112291690.davem@davemloft.net>
References: <20061121212251.GA5084@martell.zuzino.mipt.ru>
	<20061128.153325.10304536.davem@davemloft.net>
	<20061129200437.GA5152@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pavol.gono@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:11648
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S967814AbWK3Btp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 20:49:45 -0500
To: adobriyan@gmail.com
In-Reply-To: <20061129200437.GA5152@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 29 Nov 2006 23:04:37 +0300

> Looks like worker thread strategically clears it if scheduled at wrong
> moment.
> 
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -3292,7 +3292,6 @@ static void pktgen_thread_worker(struct
>  
>  	init_waitqueue_head(&t->queue);
>  
> -	t->control &= ~(T_TERMINATE);
>  	t->control &= ~(T_RUN);
>  	t->control &= ~(T_STOP);
>  	t->control &= ~(T_REMDEVALL);

Good catch Alexey.  Did you rerun the load/unload test with
this fix applied?  If it fixes things, I'll merge it.

Thanks!
