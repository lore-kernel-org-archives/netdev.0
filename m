From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 8139cp: re-enable interrupts after tx timeout
Date: Sun, 25 Nov 2012 23:43:35 +0100
Message-ID: <20121125224335.GA16561@electric-eye.fr.zoreil.com>
References: <1353782365.26346.266.camel@shinybook.infradead.org> <20121124213348.GA8313@electric-eye.fr.zoreil.com> <1353795081.26346.287.camel@shinybook.infradead.org> <20121124225855.GA17340@electric-eye.fr.zoreil.com> <1353799650.26346.289.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jasowang@redhat.com, gilboad@gmail.com,
	jgarzik@redhat.com
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46499 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753609Ab2KYXHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 18:07:47 -0500
Content-Disposition: inline
In-Reply-To: <1353799650.26346.289.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
> On Sat, 2012-11-24 at 23:58 +0100, Francois Romieu wrote:
> > While you are at it, do you see what would prevent the watchdog
> > timer and the rx napi handler to race on two different CPUs
> 
> Hm, good point. Is it sufficient just to stick napi_disable() and
> napi_enable() in there?

No, napi_disable() may sleep.

> And should we try to reset the TX state machine without stomping on
> RX at all ?

Either that or the watchdog timer will have to queue some user context
work. Things may change later when you go lockless (hint, hint).

-- 
Ueimor
