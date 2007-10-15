From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: MSI interrupts and disable_irq
Date: Mon, 15 Oct 2007 18:17:55 -0400
Message-ID: <4713E713.9060702@pobox.com>
References: <46FC15A9.1070803@nvidia.com> <46FDBCB4.9090802@pobox.com> <4710901F.8010206@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <aabdulla@nvidia.com>, nedev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Manfred Spraul <manfred@colorfullife.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39684 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431AbXJOWR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 18:17:59 -0400
In-Reply-To: <4710901F.8010206@colorfullife.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Manfred Spraul wrote:
> Jeff Garzik wrote:
>>
>> I think the scenario you outline is an illustration of the approach's 
>> fragility:  disable_irq() is a heavy hammer that originated with INTx, 
>> and it relies on a chip-specific disable method (kernel/irq/manage.c) 
>> that practically guarantees behavior will vary across MSI/INTx/etc.
>>
> I checked the code: IRQ_DISABLE is implemented in software, i.e. 
> handle_level_irq() only calls handle_IRQ_event() [and then the nic irq 
> handler] if IRQ_DISABLE is not set.
> OTHO: The last trace looks as if nv_do_nic_poll() is interrupted by an irq.
> 
> Perhaps something corrupts dev->irq? The irq is requested with
>    request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev)
> and disabled with
>    disable_irq_lockdep(dev->irq);
> 
> Someone around with a MSI capable board? The forcedeth driver does
>    dev->irq = pci_dev->irq
> in nv_probe(), especially before pci_enable_msi().
> Does pci_enable_msi() change pci_dev->irq? Then we would disable the 
> wrong interrupt....

Remember, fundamentally MSI-X is a one-to-many relationship, when you 
consider a single PCI device might have multiple vectors.

	Jeff



