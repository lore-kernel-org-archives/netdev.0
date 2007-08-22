From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: Re: [Cbe-oss-dev] [PATCH] spidernet: fix interrupt reason
 recognition
Date: Wed, 22 Aug 2007 09:26:24 +0900 (JST)
Message-ID: <200708220026.l7M0QODr013175@toshiba.co.jp>
References: <20070820223819.GK4261@austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org, arnd@arndb.de
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx12.toshiba.co.jp ([61.202.160.132]:61848 "EHLO
	imx12.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbXHVA0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 20:26:44 -0400
In-Reply-To: <20070820223819.GK4261@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> On Mon, Aug 20, 2007 at 10:13:27PM +0900, Ishizaki Kou wrote:
> > Please apply this to 2.6.23.
> 
> I'll review and forward shortly.  Kick me if you don't see a formal
> reply in a few days.
> 
> > And also, please apply the following Arnd-san's patch to fix a problem
> > that spidernet driver sometimes causes a BUG_ON at open.
> > 
> >  http://patchwork.ozlabs.org/cbe-oss-dev/patch?id=12211
> 
> Are you sure? This patch no longer applies cleanly, in part because

I see. I'll send another applicable patch.

> your patch "[PATCH] spidernet: improve interrupt handling" 
> from Mon, 09 Jul 2007 added a spider_net_enable_interrupts(card); 
> at the end of spider_net_open().  Because of this, it seems like 
> Arnd's patch is no longer needed, right?

As you pointed out, we intended that "[PATCH] spidernet: improve
interrupt handling" solves the same problem which Arnd's patch solves.

When spider_net_open() is called, interrupt reasons sometimes remain
on interrupt status register, even though they are masked by mask
register.  With this patch, spider_net_interrupt() compares the value
of interrupt status register with SPIDER_NET_INTX_MASK_VALUE, not with
interrupt mask register value.  As a result, spider_net_interrupt()
(which is called from request_irq() in spider_net_open()) starts
polling and causes BUG_ON().

So, netif_poll_enable() must be called before request_irq() is
called. This is the reason that we also need Arnd's patch.

Best regards,
Kou Ishizaki
