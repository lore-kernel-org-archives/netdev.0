From: David Fries <david@fries.net>
Subject: Re: [PATCH 2/2] ne.c msleep not mdelay
Date: Sat, 30 Aug 2008 09:57:46 -0500
Message-ID: <20080830145746.GG25161@spacedout.fries.net>
References: <20080830024453.GB24929@spacedout.fries.net> <20080830095906.6cad8647@lxorguk.ukuu.org.uk> <20080830.233647.05599714.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@lxorguk.ukuu.org.uk, linux-kernel@vger.kernel.org,
	p_gortmaker@yahoo.com, netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from SpacedOut.fries.net ([67.64.210.234]:50219 "EHLO
	SpacedOut.fries.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbYH3O6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2008 10:58:04 -0400
Content-Disposition: inline
In-Reply-To: <20080830.233647.05599714.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 30, 2008 at 11:36:47PM +0900, Atsushi Nemoto wrote:
> On Sat, 30 Aug 2008 09:59:06 +0100, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > > mdelay(10) replaced by msleep(10) to give up the CPU, it's just
> > > waiting for an interrupt, so timing isn't critical.
> > 
> > It is too critical for a reschedule to occur.
> > 
> > NAK this one.
> 
> There are already some msleep() in probe_irq_on() which is called just
> before here.  And this part is not protected by any spinlock or
> preempt_disable.

There is a probing_active mutex.  probe_irq_off has the comment
"nothing prevents two IRQ probe callers from overlapping."  Looks to me
like probing_active would prevent multiple probes from happening.

> So, if rescheduling was dangerous here, we already have potential
> problems, no?

I was just going to make the argument that any task that could be run
during msleep, could just as easily run on the other cpu in mdelay (if
there was one).

-- 
David Fries <david@fries.net>
http://fries.net/~david/ (PGP encryption key available)
