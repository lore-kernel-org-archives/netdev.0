From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/5] sky2: add fake idle irq timer
Date: Tue, 25 Apr 2006 15:45:03 -0700
Message-ID: <20060425154503.30516935@localhost.localdomain>
References: <20060425175849.372221000@localhost.localdomain>
	<20060425175951.444629000@localhost.localdomain>
	<20060425212329.GA18035@electric-eye.fr.zoreil.com>
	<20060425143042.29d636a8@localhost.localdomain>
	<20060425223900.GB18035@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27813 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932258AbWDYWpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 18:45:10 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060425223900.GB18035@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Apr 2006 00:39:00 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Stephen Hemminger <shemminger@osdl.org> :
> [...]
> > > Any objection against moving mod_timer() from sky2_poll() to sky2_idle()
> > > so as to keep poll() path unmodified ?
> > > 
> > 
> > If traffic is moving, then I want the timer to keep getting rescheduled
> > farther out.
> 
> If my version of the driver is not stale, the timer will not be
> rescheduled when work_done >= work_limit.

I am trying to work around possible lost IRQ's, not netdev scheduler
screw up's.  If workdone >= work_limit, then it will already be
called back later when it return's 1.

