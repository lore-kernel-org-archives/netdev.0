From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] spidernet: improve interrupt handling
Date: Tue, 10 Jul 2007 12:25:28 -0400
Message-ID: <4693B2F8.3070702@garzik.org>
References: <20070709231742.GQ4457@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org,
	Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59947 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454AbXGJQZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:25:33 -0400
In-Reply-To: <20070709231742.GQ4457@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
> 
> We intend this patch to improve spidernet interrupt handling to be
> more strict.  We had following problem and this patch solves it.
> 
>  -when CONFIG_DEBUG_SHIRQ=y, request_irq() calls handler().
>  -when spider_net_open() is called, it calls request_irq() which calls
>   spider_net_interrupt().
>  -if some specific interrupt bit is set at this timing, it calls
>   netif_rx_schedule() and spider_net_poll() is scheduled.
>  -spider_net_open() calls netif_poll_enable() which clears the bit 
>   __LINK_STATE_RX_SCHED.
>  -when spider_net_poll() is called, it calls netif_rx_complete() which
>   causes BUG_ON() because __LINK_STATE_RX_SCHED is not set.
> 
> Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> 
> ----
> Jeff, please apply for 2.6.23
> 
> Linas.
> 
>  drivers/net/spider_net.c |   59 +++++++++++++++++++++++++++++++++++------------
>  1 file changed, 45 insertions(+), 14 deletions(-)
> 

applied


