From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Tue, 16 Oct 2007 18:19:32 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl>
References: <20071015125301.GC3015@ff.dom.local>
 <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl> <20071016062108.GB1000@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.ds.pg.gda.pl ([153.19.208.18]:50082 "EHLO
	cerber.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760582AbXJPRTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 13:19:43 -0400
In-Reply-To: <20071016062108.GB1000@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Oct 2007, Jarek Poplawski wrote:

> Yes, it's all right here. Sorry for bothering - I should've found this
> by myself.

 Ah, no problem -- even with the right keys you may sometimes get lost in 
the results.

> I've still some doubts about this possible enable_irq() after
> free_irq(). If it's the only handler the status would be changed again
> and at least some of this code in check_irq_resend() would be run, but
> I can miss something again or/and this doesn't matter, as well.

 Well, enable_irq() and disable_irq() themselves are nesting, so they are 
not a problem.  OTOH, free_irq() does not seem to maintain the depth count 
correctly, which looks like a bug to me and which could trigger regardless 
of whether flush_scheduled_work() or cancel_work_sync() was called.

 The reason is CONFIG_DEBUG_SHIRQ which makes a simulated interrupt event 
be sent at the end of free_irq().  It looks like a problem that is 
complementary to one I signalled here:

http://lkml.org/lkml/2007/9/12/82

with respect to request_irq(), where, similarly, such an interrupt event 
is sent at the beginning.  It looks like nobody was concerned back then, 
but perhaps it is time to do a better investigation now and propose a 
solution.

 I'll think about it and thanks for your inquisitiveness that has led to 
these conclusions.

  Maciej
