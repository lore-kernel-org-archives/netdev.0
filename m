From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PCNET32] Lock solid with netconsole
Date: Tue, 29 May 2007 00:00:21 +0200
Message-ID: <20070528220021.GB4927@electric-eye.fr.zoreil.com>
References: <JIRC73$62E39331D73FCF49870995034400C560@laposte.net> <20070528183148.GA10009@csclub.uwaterloo.ca> <20070528205144.GB26309@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Emmanuel Fust? <emmanuel.fuste@laposte.net>,
	pcnet32 <pcnet32@verizon.net>, netdev <netdev@vger.kernel.org>
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:47808 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752154AbXE1WDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 18:03:54 -0400
Content-Disposition: inline
In-Reply-To: <20070528205144.GB26309@alpha.franken.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Bogendoerfer <tsbogend@alpha.franken.de> :
[...]
> for normal interrupt delivery it doesn't matter, because there shouldn't
> be any more interrupts coming in at that point. But netconsole uses
> pcnet32_interrupt for polling the chip. So if during service of a
> a real interrupt a polled pcnet32_interrupt call is done, the machine
> will deadlock.

Even if the driver-agnostic part of the irq processing can be interrupted
locally, the irq handlers are run sequentially on a given cpu. It does not
leave a lot of room for a deadlock-prone printk().

It _can_ happen but I'd prefer to pinpoint a specific candidate path
where it would have happened.

-- 
Ueimor
