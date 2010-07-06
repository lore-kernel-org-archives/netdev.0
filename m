From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/2] Export firmware assigned labels of network devices
 to sysfs
Date: Tue, 6 Jul 2010 16:22:22 -0700
Message-ID: <20100706232222.GA29632@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE612B1B@blrx3m08.blr.amer.dell.com>
 <20100706185218.GA19357@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, matt_domsch@dell.com,
	jordan_hargrave@dell.com, charles_rose@dell.com,
	vijay_nijhawan@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100706185218.GA19357@auslistsprd01.us.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 06, 2010 at 01:52:18PM -0500, Narendra K wrote:
> > -----Original Message-----
> > From: Greg KH [mailto:greg@kroah.com] 
> > Sent: Wednesday, June 30, 2010 9:12 PM
> > To: K, Narendra
> > Cc: Domsch, Matt; netdev@vger.kernel.org; linux-hotplug@vger.kernel.org;
> > linux-pci@vger.kernel.org; Hargrave, Jordan; Rose, Charles; Nijhawan,
> > Vijay
> > Subject: Re: [PATCH 1/2] Export firmware assigned labels of network
> > devices to sysfs
> > 
> > On Tue, Jun 29, 2010 at 11:28:18AM -0500, Narendra K wrote:
> > > --- a/drivers/pci/Makefile
> > > +++ b/drivers/pci/Makefile
> > > @@ -4,7 +4,7 @@
> > >  
> > >  obj-y		+= access.o bus.o probe.o remove.o pci.o \
> > >  			pci-driver.o search.o pci-sysfs.o rom.o
> > setup-res.o \
> > > -			irq.o vpd.o
> > > +			irq.o vpd.o pci-label.o
> > 
> > No, only build this if CONFIG_DMI is set.
> 
> I have corrected this to build pci-label.o if only if CONFIG_DMI is set.
> 
> 
> > > +pci_create_smbiosname_file(struct pci_dev *pdev)
> > > +{
> > > +	if (smbios_attr_label.test && smbios_attr_label.test(&pdev->dev,
> > NULL, NULL)) {
> > > +		if (sysfs_create_file(&pdev->dev.kobj,
> > &smbios_attr_label.attr))
> > > +			return -1;
> > 
> > What's wrong with the 'device_create_file' calls?
> 
> 'device_create_file' takes 'struct device_attribute *' as a param which 
> we have not used here because  'struct device_attribute' does not have .test
> member which we needed in this patch.

Why do you need it?  What is calling that function?  What am I missing
here?

> Please find the patch with the above change here -

Please always run your patches through scripts/checkpatch.pl and fix up
the issues it finds before sending it out and having everyone else point
them out to you :)

Also, a new thread is nice at times for new versions of patches...

thanks,

greg k-h
