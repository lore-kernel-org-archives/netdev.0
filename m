From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 2/2] ne.c msleep not mdelay
Date: Sat, 30 Aug 2008 15:44:47 +0100
Message-ID: <20080830154447.770aaca0@lxorguk.ukuu.org.uk>
References: <20080830024453.GB24929@spacedout.fries.net>
	<20080830095906.6cad8647@lxorguk.ukuu.org.uk>
	<20080830.233647.05599714.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: david@fries.net, linux-kernel@vger.kernel.org,
	p_gortmaker@yahoo.com, netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:33635 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751054AbYH3PB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2008 11:01:59 -0400
In-Reply-To: <20080830.233647.05599714.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There are already some msleep() in probe_irq_on() which is called just
> before here.  And this part is not protected by any spinlock or
> preempt_disable.
> 
> So, if rescheduling was dangerous here, we already have potential
> problems, no?

Yes we do but I didn't manage to stop the other mistakes getting in when
they did. If you take a schedule you get results back from the probe_irq
that tend to suck in other random ISA device events (ISA being edge
triggered nobody was ever careful about spurious irq)
