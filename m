From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] spidernet: fix interrupt reason recognition
Date: Thu, 13 Sep 2007 00:19:46 -0400
Message-ID: <46E8BA62.1090802@garzik.org>
References: <20070820.221327.-1300518791.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linas@austin.ibm.com, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59970 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752001AbXIMETv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 00:19:51 -0400
In-Reply-To: <20070820.221327.-1300518791.kouish@swc.toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ishizaki Kou wrote:
> This patch solves a problem that the spidernet driver sometimes fails
> to handle IRQ.
> 
> The problem happens because,
> - In Cell architecture, interrupts may arrive at an interrupt
>   controller, even if they are masked by the setting on registers of
>   devices. It happens when interrupt packets are sent just before 
>   the interrupts are masked.
> - spidernet interrupt handler compares interrupt reasons with
>   interrupt masks, so when such interrupts occurs, spidernet interrupt
>   handler returns IRQ_NONE.
> - When all of interrupt handler return IRQ_NONE, linux kernel disables
>   the IRQ and it no longer delivers interrupts to the interrupt handlers.
> 
> spidernet doesn't work after above sequence, because it can't receive
> interrupts.
>  
> This patch changes spidernet interrupt handler that it compares
> interrupt reason with SPIDER_NET_INTX_MASK_VALUE.
> 
> Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>

applied


