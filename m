From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] netdev: enc28j60: use IRQF_TRIGGER_FALLING for IRQ by default
Date: Tue, 26 May 2009 17:43:14 -0400
Message-ID: <200905261743.16036.vapier@gentoo.org>
References: <1243333007-25645-1-git-send-email-vapier@gentoo.org> <200905261253.07364.vapier@gentoo.org> <200905261121.54075.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Baruch Siach <baruch@tkos.co.il>,
	Michael Hennerich <michael.hennerich@analog.com>,
	netdev@vger.kernel.org, Bryan Wu <cooloney@kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:37602 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756274AbZEZVnP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2009 17:43:15 -0400
In-Reply-To: <200905261121.54075.david-b@pacbell.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 26 May 2009 14:21:53 David Brownell wrote:
> On Tuesday 26 May 2009, Mike Frysinger wrote:
> > > > You revert David Brownell's commit here
> > > > (c7b7b042068cd12b8b155722d24686f70b88ced1). Added to CC.
> > >
> > > Right ... the appended patch will *undo* the setting
> > > established in the board init code via set_irq_type().
> > >
> > > Moreover, it completely prevents working on systems which
> > > only support "both edges" triggering.
> >
> > how can it provide breakage when people are forced to use set_irq_type()
> > ?
>
> It reverses the IRQ setup done by the board code ...

how so ?  this code does the irq requesting which means the set_irq_type() 
needs to come after it anyways since the request_irq() will set any flags 
passed to it, right ?

> the code which you said they'd have to use to work
> around the breakage your patch adds.

umm, i'm referring to code the driver and you says should be put in place -- a 
call to set_irq_type() somewhere in the board init code.

> If you're really craving some change to the driver,
> you should make it take the relevant trigger type
> from the platform resource ... instead of hard-wiring
> it to a value which is *known* to break systems.

without any in-tree consumers, it's hard to see how things are supposed to be 
working and how they could possibly break
-mike
