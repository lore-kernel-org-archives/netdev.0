From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Thu, 19 Mar 2009 23:23:02 +0100
Message-ID: <20090319222302.GA1972@electric-eye.fr.zoreil.com>
References: <200903172034.55241.fzu@wemgehoertderstaat.de> <200903181300.00591.fzu@wemgehoertderstaat.de> <20090318223629.GA2306@electric-eye.fr.zoreil.com> <200903191158.52436.fzu@wemgehoertderstaat.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Rafael Wysocki <rjw@sisk.pl>
To: Karsten Wiese <fzu@wemgehoertderstaat.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35357 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756163AbZCSWTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 18:19:33 -0400
Content-Disposition: inline
In-Reply-To: <200903191158.52436.fzu@wemgehoertderstaat.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karsten Wiese <fzu@wemgehoertderstaat.de> :
[...]
> Found it: CONFIG_DEBUG_SHIRQ is set here causing a "test-call" to
> rtl8169_interrupt() from irq_request().
> 
> $SUBJECT patch is ok, me still thinks. You ?

I will have to convince myself that nothing bad can happen in the
window between netif_rx_schedule_prep and RTL_W16. No big deal.

I do not understand why / how the patch works at all : AFAIU, the status
register must contain some napi-related event in order for the patch to
make a difference. That's exactly what rtl8169_irq_mask_and_ack() is
supposed to prevent. -> Does it fail ?

So I'd really like to understand what is going on here.

PS: while I agree on the motivation for CONFIG_DEBUG_SHIRQ, I wonder if
it is 100% safe to run an IRQ handler from a context which does not
adhere to the original semantic. If its {disable/enable}_irq pair races
with a similar pair due to a different driver on the same (shared) irq,
things could imho be unsafe.

-- 
Ueimor
