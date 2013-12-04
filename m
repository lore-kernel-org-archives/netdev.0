From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: [PATCH] xen/pvhvm: If xen_platform_pci=0 is set don't blow up.
Date: Wed, 4 Dec 2013 10:51:55 +0000
Message-ID: <alpine.DEB.2.02.1312041049310.7093@kaball.uk.xensource.com>
References: <1386105246-14337-1-git-send-email-konrad.wilk@oracle.com> <1386149848.13256.86.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	<stefano.stabellini@eu.citrix.com>,
	<xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>,
	<boris.ostrovsky@oracle.com>, <david.vrabel@citrix.com>,
	<leosilva@linux.vnet.ibm.com>, <ashley@ashleylai.com>,
	<peterhuewe@gmx.de>, <mail@srajiv.net>, <tpmdd@selhorst.net>,
	<tpmdd@sirrix.com>, <dmitry.torokhov@gmail.com>,
	<bhelgaas@google.com>, <plagnioj@jcrosoft.com>,
	<tomi.valkeinen@ti.com>, <tpmdd-devel@lists.sourceforge.net>,
	<linux-input@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <linux-fbdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1386149848.13256.86.camel@kazak.uk.xensource.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Dec 2013, Ian Campbell wrote:
> > +bool xen_has_pv_devices(void)
> > +{
> > +	if (!xen_domain())
> > +		return false;
> > +
> > +	if (xen_hvm_domain()) {
> > +		/* User requested no unplug, so no PV drivers. */
> > +		if (xen_emul_unplug & XEN_UNPLUG_NEVER)
> > +			return false;
> 
> I think you need
> 		if (xen_emul_unpug & XEN_UNPLUG_UNNECESSARY)
> 			return true;
> don't you?

XEN_UNPLUG_UNNECESSARY was introduced to enable the platform PCI device
even if it didn't respond properly to the unplug protocol.
The corresponding parameter is called "unnecessary" because if you pass
it to the kernel you mean that it is unnecessary to unplug the emulated
devices but you can use the pv devices anyway.

So no, we shouldn't check for XEN_UNPLUG_UNNECESSARY here.



> > +		/* And user has xen_platform_pci=0 set in guest config as
> > +		 * driver did not modify the value. */
> > +		if (!xen_platform_pci_unplug)
> > +			return false;
> > +	}
> > +	return true;
> > +}
> > +EXPORT_SYMBOL_GPL(xen_has_pv_devices);
> > +
> >  void xen_unplug_emulated_devices(void)
> >  {
> >  	int r;
> 
> 
