From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: MSI interrupts and disable_irq
Date: Sun, 14 Oct 2007 12:55:18 -0700
Message-ID: <86802c440710141255l3a02c50eja7b4b1b77aa8c1d8@mail.gmail.com>
References: <46FC15A9.1070803@nvidia.com> <46FDBCB4.9090802@pobox.com>
	 <4710901F.8010206@colorfullife.com>
	 <86802c440710132259o6e82f6s4bed7b25bd5636e9@mail.gmail.com>
	 <4711C217.2010605@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
	"Ayaz Abdulla" <aabdulla@nvidia.com>,
	nedev <netdev@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "Manfred Spraul" <manfred@colorfullife.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:29302 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167AbXJNTzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 15:55:19 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1702459wah
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2007 12:55:18 -0700 (PDT)
In-Reply-To: <4711C217.2010605@colorfullife.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/14/07, Manfred Spraul <manfred@colorfullife.com> wrote:
> Yinghai Lu wrote:
> > On 10/13/07, Manfred Spraul <manfred@colorfullife.com> wrote:
> >
> >> Someone around with a MSI capable board? The forcedeth driver does
> >>     dev->irq = pci_dev->irq
> >> in nv_probe(), especially before pci_enable_msi().
> >> Does pci_enable_msi() change pci_dev->irq? Then we would disable the
> >> wrong interrupt....
> >>
> >
> > the request_irq==>setup_irq will make dev->irq = pci_dev->irq.
> >
> >
> Where is that?

in nv_request_irq
                if ((ret = pci_enable_msi(np->pci_dev)) == 0) {
                        np->msi_flags |= NV_MSI_ENABLED;
                        if (request_irq(np->pci_dev->irq, handler,
IRQF_SHARED, dev->name, dev) != 0) {

in request_irq

int request_irq(unsigned int irq, irq_handler_t handler,
                unsigned long irqflags, const char *devname, void *dev_id)
...
        action->dev_id = dev_id;
...
        retval = setup_irq(irq, action);

in setup_irq
int setup_irq(unsigned int irq, struct irqaction *new)
....
        new->irq = irq;

it seems I missed that here new is irqaction instead of net_dev.

YH
