From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [V4 PATCH 3/6] pci: Generic function for setting up PCI device
 DMA coherency
Date: Wed, 20 May 2015 10:34:01 +0100
Message-ID: <20150520093401.GC25313@e104818-lin.cambridge.arm.com>
References: <1431724994-21601-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <3954735.qeaTp8qOcM@vostro.rjw.lan>
 <20150520092415.GA25313@e104818-lin.cambridge.arm.com>
 <2072233.lIH4idDurI@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org,
	will.deacon@arm.com, herbert@gondor.apana.org.au,
	al.stone@linaro.org, linux-acpi@vger.kernel.org,
	Murali Karicheri <m-karicheri2@ti.com>, msalter@redhat.com,
	grant.likely@linaro.org, hanjun.guo@linaro.org,
	thomas.lendacky@amd.com, Rob Herring <robh+dt@kernel.org>,
	bhelgaas@google.com, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	linux-kernel@vger.kernel.org, leo.duran@amd.com,
	linux-crypto@vger.kernel.org,
	Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
	lenb@kernel.org, David Woodhouse <dwmw2@infradead.org>,
	davem@davemloft.net
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2072233.lIH4idDurI@wuerfel>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 20, 2015 at 11:27:54AM +0200, Arnd Bergmann wrote:
> On Wednesday 20 May 2015 10:24:15 Catalin Marinas wrote:
> > On Sat, May 16, 2015 at 01:59:00AM +0200, Rafael J. Wysocki wrote:
> > > On Friday, May 15, 2015 04:23:11 PM Suravee Suthikulpanit wrote:
> > > > +/**
> > > > + * pci_dma_configure - Setup DMA configuration
> > > > + * @pci_dev: ptr to pci_dev struct of the PCI device
> > > > + *
> > > > + * Function to update PCI devices's DMA configuration using the same
> > > > + * info from the OF node or ACPI node of host bridge's parent (if any).
> > > > + */
> > > > +static void pci_dma_configure(struct pci_dev *pci_dev)
> > > > +{
> > > > +   struct device *dev = &pci_dev->dev;
> > > > +   struct device *bridge = pci_get_host_bridge_device(pci_dev);
> > > > +   struct device *host = bridge->parent;
> > > > +   struct acpi_device *adev;
> > > > +
> > > > +   if (!host)
> > > > +           return;
> > > > +
> > > > +   if (acpi_disabled) {
> > > > +           of_dma_configure(dev, host->of_node);
> > > 
> > > I'd rather do
> > > 
> > >       if (IS_ENABLED(CONFIG_OF) && host->of_node) {
> > >               of_dma_configure(dev, host->of_node);
> > 
> > Nitpick: do we need the CONFIG_OF check? If disabled, I don't think
> > anyone would set host->of_node.
> 
> If of_dma_configure() is defined in a file that is built conditionally
> based on CONFIG_OF, you need it.

We have a dummy of_dma_configure() already when !CONFIG_OF, otherwise
we would need #ifndef here. I already replied, I think for other
architectures we need this check to avoid a useless host->of_node test.

-- 
Catalin
