From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: enc28j60: use IRQF_TRIGGER_FALLING for IRQ by
 default
Date: Tue, 26 May 2009 20:53:42 -0700 (PDT)
Message-ID: <20090526.205342.239598826.davem@davemloft.net>
References: <200905261121.54075.david-b@pacbell.net>
	<200905261743.16036.vapier@gentoo.org>
	<200905261817.07161.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vapier@gentoo.org, baruch@tkos.co.il, michael.hennerich@analog.com,
	netdev@vger.kernel.org, cooloney@kernel.org
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47506
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754764AbZE0Dxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 23:53:43 -0400
In-Reply-To: <200905261817.07161.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <david-b@pacbell.net>
Date: Tue, 26 May 2009 18:17:06 -0700

> Wrong.  A set_irq_type() call ensures the IRQ will trigger as
> specified by its parameters (unless it fails).  The current
> request_irq() leaves that "default" setup alone.
> 
> Your patch changes that configuration, making it request
> a trigger mode that (a) the hardware may not support, so
> the request_irq() will fail; else if it succeeds, then
> (b) will clobber whatever mode that was already set up.
> The first certainly breaks things; the second probably
> does so.

I totally agree with David, this patch seems to be wrong on
just about every possible level.
