From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/6] sky2: fix hang on shutdown (and other irq issues)
Date: Thu, 17 Nov 2011 09:01:04 -0800
Message-ID: <20111117090104.002e110a@s6510.linuxnetplumber.net>
References: <20111116234254.319625694@vyatta.com>
	<20111116234344.526517614@vyatta.com>
	<87r517w2z0.fsf@turtle.gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sven Joachim <svenjoac@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39841 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932391Ab1KQRBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 12:01:08 -0500
In-Reply-To: <87r517w2z0.fsf@turtle.gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Nov 2011 09:46:43 +0100
Sven Joachim <svenjoac@gmx.de> wrote:

> On 2011-11-17 00:42 +0100, Stephen Hemminger wrote:
> 
> > There are several problems with recent change to how IRQ's are setup.
> >    * synchronize_irq in sky2_shutdown would hang because there
> >      was no IRQ setup.
> >    * when device was set to down, some IRQ bits left enabled so a
> >      hardware error would produce IRQ with no handler
> >    * quick link on Optima chip set was enabled without handler
> >    * suspend/resume would leave IRQ on with no handler if device
> >      was down
> 
> Unfortunately, this patch does not fix the hang at shutdown for me. :-(

You are probably stuck in some part of the code path in sky2_shutdown.
The best debug for this is sprinkling the code printk's. That is how I
narrowed the problem down to synchronize_irq.
