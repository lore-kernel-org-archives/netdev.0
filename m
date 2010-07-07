From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/2] Export firmware assigned labels of network devices
 to sysfs
Date: Wed, 7 Jul 2010 11:11:34 -0700
Message-ID: <20100707181134.GB4293@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE612B27@blrx3m08.blr.amer.dell.com>
 <20100707174826.GA1046@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, matt_domsch@dell.com,
	jordan_hargrave@dell.com, charles_rose@dell.com,
	vijay_nijhawan@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100707174826.GA1046@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 07, 2010 at 12:48:26PM -0500, Narendra K wrote:
> > -----Original Message-----
> > From: Greg KH [mailto:greg@kroah.com] 
> > Sent: Wednesday, July 07, 2010 4:52 AM
> > To: K, Narendra
> > Cc: netdev@vger.kernel.org; linux-hotplug@vger.kernel.org;
> > linux-pci@vger.kernel.org; Domsch, Matt; Hargrave, Jordan; Rose,
> > Charles; Nijhawan, Vijay
> > Subject: Re: [PATCH 1/2] Export firmware assigned labels of network
> > devices to sysfs
> > 
> > On Tue, Jul 06, 2010 at 01:52:18PM -0500, Narendra K wrote:
> > > 
> > > 'device_create_file' takes 'struct device_attribute *' as a param
> > which 
> > > we have not used here because  'struct device_attribute' does not have
> > .test
> > > member which we needed in this patch.
> > 
> > Why do you need it?  What is calling that function?  What am I missing
> > here?
> 
> The function 'pci_create_smbiosname_file' below is calling the .test method.
> For every pdev the function checks if it has a SMBIOS string associated
> with it or not. If there is no string (and instance) associated, then the
> attributes 'label' and 'instance' are not created for that pdev.
> To check for the existance of the string, the .test method is needed and
> it is not available in 'struct device_attribute'. It provides 
> .show and .store. We need a .show and .test. So we defined 

{sigh}

So, you just reinvented the is_visible function in struct
attribute_group?  Please use the infrastructure already available to do
this, it saves on code and debugging and review time.

thanks,

greg k-h
