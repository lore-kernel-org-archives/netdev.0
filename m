From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Tue, 13 Jun 2006 20:33:22 -0400
Message-ID: <448F5952.1060201@pobox.com>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org> <20060613235531.GA4191@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Valerie Henson <val_henson@linux.intel.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:63911 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932375AbWFNAda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 20:33:30 -0400
To: Grant Grundler <grundler@parisc-linux.org>
In-Reply-To: <20060613235531.GA4191@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grant Grundler wrote:
> o tulip_stop_rxtx() has to be called _after_ free_irq().
>   ie. v2 patch didn't fix the original race condition
>   and when under test, dies about as fast as the original code.

You made the race window smaller, but it's still there.  The chip's DMA 
engines should be stopped before you unregister the interrupt handler.

	Jeff



