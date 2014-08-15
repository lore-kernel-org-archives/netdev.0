From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: Issue with commit 33c133cc7598e60976a phy: IRQ cannot be shared
Date: Fri, 15 Aug 2014 17:39:05 +0400
Message-ID: <53EE0D79.3020809@cogentembedded.com>
References: <53EC57B9.8080903@c-s.fr> <53EC9783.3020809@cogentembedded.com> <53EDCE6F.9000307@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: christophe leroy <christophe.leroy@c-s.fr>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:51545 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbaHONjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 09:39:09 -0400
Received: by mail-la0-f48.google.com with SMTP id gl10so2342839lab.35
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 06:39:07 -0700 (PDT)
In-Reply-To: <53EDCE6F.9000307@c-s.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/15/2014 01:10 PM, christophe leroy wrote:

>>> I have an hardware with two ethernet interfaces, and with the two PHYs inside
>>> the same component INTEL LXT973 which has only one interrupt.
>>> I also have another hardware with two ethernet interfaces and two independant
>>> PHYs. But the two PHYs are wired to the same interrupt.
>>> This is working perfectly up to Linux 3.12.

>>    Hm, I'm surprised it works. Are you sure you're getting interrupts from
>> both PHYs? Because if both Ethernet controllers are active simultaneously,
>> only the first registered PHY IRQ handler should get all the interrupts.

> Yes it works. Why should only the first one get the interrupts ?
> handle_irq_event_percpu() (from kernel/irq/handle.c, extract below) calls all
> handlers regardless of whether they answer IRQ_NONE or IRQ_HANDLED. The break
> applies to the switch(), not to the while(). So all handlers are called.

    Indeed, my reasoning seems obsolete now, if ever valid at all. :-/
    I couldn't yet remember other reasons that caused me to do that patch last 
December. Perhaps it was also connected to the "rude" behaviour of the 
phylib's IRQ handler, which calls disable_irq_nosync()...

[...]

>>> Reading the commit log, I can't really understand the reason for the change.

>>> Is it really worth it, and therefore how shall my case be handled ?

>>    PHY IRQs are not necessary for the phylib state machine.

> However, polling is less efficient than IRQs. It wastes CPU and link loss
> detection is slower.

    Yes, but you can't avoid it even with valid IRQ, the way phylib is 
written: the state workqueue is activated once a second even in the absence of 
interrupts.

    What can also be done is getting rid of the IRQ workqueue and using 
threaded IRQs,

> BR
> Christophe

WBR, Sergei
