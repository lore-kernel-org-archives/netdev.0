From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] airo: make debug-like messages printed by
	airo_print_dbg()
Date: Sun, 09 Jul 2006 10:24:04 -0400
Message-ID: <1152455044.2519.7.camel@localhost.localdomain>
References: <44AFD651.8030801@net-pr.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52633 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1161004AbWGIOX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2006 10:23:28 -0400
To: Robert Schulze <rob@net-pr.de>
In-Reply-To: <44AFD651.8030801@net-pr.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-07-08 at 17:59 +0200, Robert Schulze wrote:
> I don't think that messages like
> 
> airo(eth1): cmd= 111
> 
> airo(eth1): status= 7f11
> 
> airo(eth1): Rsp0= 2
> 
> airo(eth1): Rsp1= 0
> 
> airo(eth1): Rsp2= 0
> 
> are interesting to normal users, so switch them from airo_print_err() to airo_print_dbg().
> Furthermore, remove implicit linefeed in those messages, as they are handled by airo_print().

+1.  If you wanted to get a bit more creative, maybe collapse all of
these onto a single line to print something like:

airo(eth1): Command didn't complete. cmd:0x111 status:0x7f11 (Rsp: 2, 0,
0)

This message will only happen if the card hangs up and stops responding
to commands anyway, so we don't necessarily care about making the
message decipherable to anyone other than developers.

Dan

> with kind regards,
> Robert Schulze
> 
> --- linux-2.6.17.1/drivers/net/wireless/airo.c.orig	2006-07-08 14:02:12.000000000 +0200
> +++ linux-2.6.17.1/drivers/net/wireless/airo.c	2006-07-08 17:36:08.000000000 +0200
> @@ -3897,11 +3897,11 @@ static u16 issuecommand(struct airo_info
>   	pRsp->rsp1 = IN4500(ai, RESP1);
>   	pRsp->rsp2 = IN4500(ai, RESP2);
>   	if ((pRsp->status & 0xff00)!=0 && pCmd->cmd != CMD_SOFTRESET) {
> -		airo_print_err(ai->dev->name, "cmd= %x\n", pCmd->cmd);
> -		airo_print_err(ai->dev->name, "status= %x\n", pRsp->status);
> -		airo_print_err(ai->dev->name, "Rsp0= %x\n", pRsp->rsp0);
> -		airo_print_err(ai->dev->name, "Rsp1= %x\n", pRsp->rsp1);
> -		airo_print_err(ai->dev->name, "Rsp2= %x\n", pRsp->rsp2);
> +		airo_print_dbg(ai->dev->name, "cmd= %x", pCmd->cmd);
> +		airo_print_dbg(ai->dev->name, "status= %x", pRsp->status);
> +		airo_print_dbg(ai->dev->name, "Rsp0= %x", pRsp->rsp0);
> +		airo_print_dbg(ai->dev->name, "Rsp1= %x", pRsp->rsp1);
> +		airo_print_dbg(ai->dev->name, "Rsp2= %x", pRsp->rsp2);
>   	}
> 
>   	// clear stuck command busy if necessary
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

