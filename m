From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [proposed patch] via-rhine: prevent oops when requesting an IRQ
Date: Mon, 10 Nov 2008 17:35:14 -0500
Message-ID: <4918B722.8020703@garzik.org>
References: <20081104192357.2b0dbe22@redhat.com>	<491289AD.9070401@garzik.org> <20081110172836.0aaec702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33269 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752763AbYKJWfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 17:35:17 -0500
In-Reply-To: <20081110172836.0aaec702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Ebbert wrote:
> On Thu, 06 Nov 2008 01:07:41 -0500
> Jeff Garzik <jeff@garzik.org> wrote:
> 
>> Chuck Ebbert wrote:
>>> via-rhine: prevent oops when requesting an IRQ
>>>
>>> via-rhine requests an IRQ before it's ready to handle an interrupt.
>>> It oopses when CONFIG_DEBUG_SHIRQ is enabled.
>>>
>>> https://bugzilla.redhat.com/show_bug.cgi?id=469303
>>>
>>> ---
>>>
>>> NOTE: UNTESTED: Is it okay to init the hardware before requesting the
>>> IRQ, or should that be done afterward?
>> First of all, _ideally_ your interrupt handler should be able to any 
>> state of software initialization, once registers are mapped.  So I would 
>> first concentrate on "hardening" the interrupt handler, if feasible.
>>
>> It is certainly a common technique to disable interrupts somehow, during 
>> initialization of the hardware.  Note, though, that doing things before 
>> request_irq() is no real guarantee you are out of danger -- you might be 
>> on a shared PCI irq, and your init causes that interrupt to "scream" 
>> even though your driver has not registered the irq.
>>
> 
> The problem with this driver is that it doesn't call alloc_ring() before
> request_irq() and then it oopses in the interrupt handler trying to access
> the ring.

Allocation should definitely occur prior to request_irq()

	Jeff


