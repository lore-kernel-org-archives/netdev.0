From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] spidernet: fix interrupt reason recognition
Date: Tue, 4 Sep 2007 18:49:54 -0500
Message-ID: <20070904234954.GL4584@austin.ibm.com>
References: <20070820.221327.-1300518791.kouish@swc.toshiba.co.jp> <46D7F179.5070808@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:52146 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754426AbXIDXt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2007 19:49:56 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l84NnuUC017923
	for <netdev@vger.kernel.org>; Tue, 4 Sep 2007 19:49:56 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l84NnuQC695068
	for <netdev@vger.kernel.org>; Tue, 4 Sep 2007 19:49:56 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l84NntQr024243
	for <netdev@vger.kernel.org>; Tue, 4 Sep 2007 19:49:56 -0400
Content-Disposition: inline
In-Reply-To: <46D7F179.5070808@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 06:46:17AM -0400, Jeff Garzik wrote:
> Ishizaki Kou wrote:
> >This patch solves a problem that the spidernet driver sometimes fails
> >to handle IRQ.
> >
> >The problem happens because,
> >- In Cell architecture, interrupts may arrive at an interrupt
> >  controller, even if they are masked by the setting on registers of
> >  devices. It happens when interrupt packets are sent just before 
> >  the interrupts are masked.
> >- spidernet interrupt handler compares interrupt reasons with
> >  interrupt masks, so when such interrupts occurs, spidernet interrupt
> >  handler returns IRQ_NONE.
> >- When all of interrupt handler return IRQ_NONE, linux kernel disables
> >  the IRQ and it no longer delivers interrupts to the interrupt handlers.
> >
> >spidernet doesn't work after above sequence, because it can't receive
> >interrupts.
> > 
> >This patch changes spidernet interrupt handler that it compares
> >interrupt reason with SPIDER_NET_INTX_MASK_VALUE.
> >
> >Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
> >---
> >
> >Linas-san,
> >
> >Please apply this to 2.6.23. Because this problem is sometimes happens
> >and we cannot use the ethernet port any more.
> >
> >And also, please apply the following Arnd-san's patch to fix a problem
> >that spidernet driver sometimes causes a BUG_ON at open.
> 
> Linas?  ACK?  Alive?  :)

Argh. I read the code; it looked fine. I was going to compile it and
forward it formally and etc. and then I got busy ...

Ack'ed by: Linas Vepstas <linas@austin.ibm.com>

--linas
