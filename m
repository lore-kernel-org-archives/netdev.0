From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH] PCI: Update ACS quirk for more Intel 10G NICs
Date: Thu, 3 Aug 2017 16:16:23 -0600
Message-ID: <20170803161623.31e5fb86@w520.home>
References: <20170720214101.7449-1-roland@kernel.org>
        <20170803214911.GG20308@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@kernel.org>,
        Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, Emil Tantilov <emil.s.tantilov@intel.com>
To: Bjorn Helgaas <helgaas@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43530 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751599AbdHCWQZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 18:16:25 -0400
In-Reply-To: <20170803214911.GG20308@bhelgaas-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Aug 2017 16:49:11 -0500
Bjorn Helgaas <helgaas@kernel.org> wrote:

> On Thu, Jul 20, 2017 at 02:41:01PM -0700, Roland Dreier wrote:
> > From: Roland Dreier <roland@purestorage.com>
> > 
> > Add one more variant of the 82599 plus the device IDs for X540 and X550
> > variants.  Intel has confirmed that none of these devices does peer-to-peer
> > between functions.  The X540 and X550 have added ACS capabilities in their
> > PCI config space, but the ACS control register is hard-wired to 0 for both
> > devices, so we still need the quirk for IOMMU grouping to allow assignment
> > of individual SR-IOV functions.
> > 
> > Signed-off-by: Roland Dreier <roland@purestorage.com>  
> 
> I haven't seen a real conclusion to the discussion yet, so I'm waiting on
> that and hopefully an ack from Alex.  Can you please repost with that,
> since I'm dropping it from patchwork for now?

I think the conclusion is that a hard-wired ACS capability is a
positive indication of isolation for a multifunction device, the code
is intended to support this and appears to do so, and Roland was going
to investigate the sightings that inspired this patch in more detail.
Dropping for now is appropriate.  Thanks,

Alex

> > ---
> >  drivers/pci/quirks.c | 21 +++++++++++++++++++++
> >  1 file changed, 21 insertions(+)
> > 
> > diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
> > index 6967c6b4cf6b..b939db671326 100644
> > --- a/drivers/pci/quirks.c
> > +++ b/drivers/pci/quirks.c
> > @@ -4335,12 +4335,33 @@ static const struct pci_dev_acs_enabled {
> >  	{ PCI_VENDOR_ID_INTEL, 0x1507, pci_quirk_mf_endpoint_acs },
> >  	{ PCI_VENDOR_ID_INTEL, 0x1514, pci_quirk_mf_endpoint_acs },
> >  	{ PCI_VENDOR_ID_INTEL, 0x151C, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x1528, pci_quirk_mf_endpoint_acs },
> >  	{ PCI_VENDOR_ID_INTEL, 0x1529, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x154A, pci_quirk_mf_endpoint_acs },
> >  	{ PCI_VENDOR_ID_INTEL, 0x152A, pci_quirk_mf_endpoint_acs },
> >  	{ PCI_VENDOR_ID_INTEL, 0x154D, pci_quirk_mf_endpoint_acs },
> >  	{ PCI_VENDOR_ID_INTEL, 0x154F, pci_quirk_mf_endpoint_acs },
> >  	{ PCI_VENDOR_ID_INTEL, 0x1551, pci_quirk_mf_endpoint_acs },
> >  	{ PCI_VENDOR_ID_INTEL, 0x1558, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x1560, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x1563, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15AA, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15AB, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15AC, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15AD, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15AE, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15B0, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15AB, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15C2, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15C3, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15C4, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15C6, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15C7, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15C8, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15CE, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15E4, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15E5, pci_quirk_mf_endpoint_acs },
> > +	{ PCI_VENDOR_ID_INTEL, 0x15D1, pci_quirk_mf_endpoint_acs },
> >  	/* 82580 */
> >  	{ PCI_VENDOR_ID_INTEL, 0x1509, pci_quirk_mf_endpoint_acs },
> >  	{ PCI_VENDOR_ID_INTEL, 0x150E, pci_quirk_mf_endpoint_acs },
> > -- 
> > 2.11.0
> >   
