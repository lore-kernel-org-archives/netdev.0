From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] airo: make debug-like messages printed
	by	airo_print_dbg()
Date: Sun, 09 Jul 2006 23:12:46 -0400
Message-ID: <1152501166.12503.3.camel@localhost.localdomain>
References: <44AFD651.8030801@net-pr.de>
	 <1152455044.2519.7.camel@localhost.localdomain>
	 <44B13974.9090604@net-pr.de> <44B1431D.3010405@tls.msk.ru>
	 <44B181D5.5070007@net-pr.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Tokarev <mjt@tls.msk.ru>, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52113 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1161315AbWGJDM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2006 23:12:26 -0400
To: Robert Schulze <rob@net-pr.de>
In-Reply-To: <44B181D5.5070007@net-pr.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-10 at 00:23 +0200, Robert Schulze wrote:
> Hi,
> 
> ok lets keep that message to be visible to anybody, but put it into one line.
> Thanks for your comments.
> Now, I will track down what causes the error on my machine, I think it has something todo with pcmcia...

Looks good.  This will happen any time the driver tries to talk to the
card but can't.  So you might want to try looking at whether the card is
already pulled out or its resources have been deallocated before this
code runs.  Obviously we can talk to the card up until it's been pulled
out and the kernel notifies us that the card has been unplugged, but
perhaps there's a codepath that tries to mistakenly handle both
hot-unplug and module removal by writing something to that card (like
reset commands).  I've seen that before in other places.

Dan

> with kind regards,
> 
> Robert Schulze
> 
> --- linux-2.6.17.1/drivers/net/wireless/airo.c.orig	2006-07-08 14:02:12.000000000 +0200
> +++ linux-2.6.17.1/drivers/net/wireless/airo.c	2006-07-10 00:19:15.000000000 +0200
> @@ -3897,11 +3897,10 @@ static u16 issuecommand(struct airo_info
>   	pRsp->rsp1 = IN4500(ai, RESP1);
>   	pRsp->rsp2 = IN4500(ai, RESP2);
>   	if ((pRsp->status & 0xff00)!=0 && pCmd->cmd != CMD_SOFTRESET) {
> -		airo_print_err(ai->dev->name, "cmd= %x\n", pCmd->cmd);
> -		airo_print_err(ai->dev->name, "status= %x\n", pRsp->status);
> -		airo_print_err(ai->dev->name, "Rsp0= %x\n", pRsp->rsp0);
> -		airo_print_err(ai->dev->name, "Rsp1= %x\n", pRsp->rsp1);
> -		airo_print_err(ai->dev->name, "Rsp2= %x\n", pRsp->rsp2);
> +		airo_print_err(ai->dev->name,
> +			"cmd:%x status:%x rsp0:%x rsp1:%x rsp2:%x"
> +			pCmd->cmd, pRsp->status, pRsp->rsp0, pRsp->rsp1,
> +			pRsp->rsp2);
>   	}
> 
>   	// clear stuck command busy if necessary

