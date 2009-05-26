From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] netdev: enc28j60: use IRQF_TRIGGER_FALLING for IRQ by default
Date: Tue, 26 May 2009 11:21:53 -0700
Message-ID: <200905261121.54075.david-b@pacbell.net>
References: <1243333007-25645-1-git-send-email-vapier@gentoo.org> <200905260424.17654.david-b@pacbell.net> <200905261253.07364.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Baruch Siach <baruch@tkos.co.il>,
	Michael Hennerich <michael.hennerich@analog.com>,
	netdev@vger.kernel.org, Bryan Wu <cooloney@kernel.org>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n17.bullet.mail.mud.yahoo.com ([68.142.206.144]:24063 "HELO
	n17.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754091AbZEZSVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 14:21:54 -0400
In-Reply-To: <200905261253.07364.vapier@gentoo.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 26 May 2009, Mike Frysinger wrote:
> > > You revert David Brownell's commit here
> > > (c7b7b042068cd12b8b155722d24686f70b88ced1). Added to CC.
> >
> > Right ... the appended patch will *undo* the setting
> > established in the board init code via set_irq_type().
> >
> > Moreover, it completely prevents working on systems which
> > only support "both edges" triggering.
> 
> how can it provide breakage when people are forced to use set_irq_type() ?

It reverses the IRQ setup done by the board code ...
the code which you said they'd have to use to work
around the breakage your patch adds.

If you're really craving some change to the driver,
you should make it take the relevant trigger type
from the platform resource ... instead of hard-wiring
it to a value which is *known* to break systems.

