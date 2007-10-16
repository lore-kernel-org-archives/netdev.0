From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: MSI interrupts and disable_irq
Date: Tue, 16 Oct 2007 10:23:20 -0700
Message-ID: <86802c440710161023p3fbd6832gdb6d10a1b5e9d932@mail.gmail.com>
References: <46FC15A9.1070803@nvidia.com> <46FDBCB4.9090802@pobox.com>
	 <4710901F.8010206@colorfullife.com> <4713E713.9060702@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Manfred Spraul" <manfred@colorfullife.com>,
	"Ayaz Abdulla" <aabdulla@nvidia.com>,
	nedev <netdev@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:62892 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934385AbXJPRXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 13:23:22 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1485275rvb
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 10:23:21 -0700 (PDT)
In-Reply-To: <4713E713.9060702@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/15/07, Jeff Garzik <jgarzik@pobox.com> wrote:
> Manfred Spraul wrote:
> > Jeff Garzik wrote:
> >>
> >> I think the scenario you outline is an illustration of the approach's
> >> fragility:  disable_irq() is a heavy hammer that originated with INTx,
> >> and it relies on a chip-specific disable method (kernel/irq/manage.c)
> >> that practically guarantees behavior will vary across MSI/INTx/etc.
> >>
> > I checked the code: IRQ_DISABLE is implemented in software, i.e.
> > handle_level_irq() only calls handle_IRQ_event() [and then the nic irq
> > handler] if IRQ_DISABLE is not set.
> > OTHO: The last trace looks as if nv_do_nic_poll() is interrupted by an irq.
> >
> > Perhaps something corrupts dev->irq? The irq is requested with
> >    request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev)
> > and disabled with
> >    disable_irq_lockdep(dev->irq);
> >
> > Someone around with a MSI capable board? The forcedeth driver does
> >    dev->irq = pci_dev->irq
> > in nv_probe(), especially before pci_enable_msi().
> > Does pci_enable_msi() change pci_dev->irq? Then we would disable the
> > wrong interrupt....
>
> Remember, fundamentally MSI-X is a one-to-many relationship, when you
> consider a single PCI device might have multiple vectors.

msi-x is using other entry

               if (np->msi_flags & NV_MSI_X_ENABLED)

enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);

YH
