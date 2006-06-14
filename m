From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Wed, 14 Jun 2006 11:03:48 -0400
Message-ID: <44902554.7010703@pobox.com>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org> <20060613235531.GA4191@colo.lackof.org> <448F5952.1060201@pobox.com> <20060614044412.GA30552@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Valerie Henson <val_henson@linux.intel.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:12226 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964992AbWFNPDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 11:03:54 -0400
To: Grant Grundler <grundler@parisc-linux.org>
In-Reply-To: <20060614044412.GA30552@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grant Grundler wrote:
> On Tue, Jun 13, 2006 at 08:33:22PM -0400, Jeff Garzik wrote:
>> Grant Grundler wrote:
>>> o tulip_stop_rxtx() has to be called _after_ free_irq().
>>>  ie. v2 patch didn't fix the original race condition
>>>  and when under test, dies about as fast as the original code.
>> You made the race window smaller, but it's still there.  The chip's DMA 
>> engines should be stopped before you unregister the interrupt handler.
> 
> Switching the order to be:
>         tulip_stop_rxtx(tp);            /* Stop DMA */
>         free_irq (dev->irq, dev);       /* no more races after this */
> 
> still leaves us open to IRQs being delivered _after_ we've stopped DMA.

Correct.  And that is the preferred, natural, logical, obvious order:

1) Turn things off.
2) Wait for activity to cease.


> That in turn allows the interrupt handler to re-enable DMA again.

Then that would be a problem to solve...  Some interrupt handlers will 
test netif_running() or a driver-specific shutting-down flag, 
specifically to avoid such behaviors.

	Jeff



