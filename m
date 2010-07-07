From: "Domsch, Matt" <Matt_Domsch@Dell.com>
Subject: Re: [PATCH 1/2] Export firmware assigned labels of network devices
 to sysfs
Date: Wed, 7 Jul 2010 13:35:59 -0500
Message-ID: <20100707183543.GA6870@mdomsch-pws380.aus.amer.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE612B27@blrx3m08.blr.amer.dell.com>
 <20100707174826.GA1046@auslistsprd01.us.dell.com>
 <20100707181134.GB4293@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "K, Narendra" <Narendra_K@Dell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>,
	"Nijhawan, Vijay" <Vijay_Nijhawan@Dell.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100707181134.GB4293@kroah.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 07, 2010 at 01:11:34PM -0500, Greg KH wrote:
> > > Why do you need it?  What is calling that function?  What am I missing
> > > here?
> > 
> > The function 'pci_create_smbiosname_file' below is calling the .test method.
> > For every pdev the function checks if it has a SMBIOS string associated
> > with it or not. If there is no string (and instance) associated, then the
> > attributes 'label' and 'instance' are not created for that pdev.
> > To check for the existance of the string, the .test method is needed and
> > it is not available in 'struct device_attribute'. It provides 
> > .show and .store. We need a .show and .test. So we defined 
> 
> {sigh}
> 
> So, you just reinvented the is_visible function in struct
> attribute_group?  Please use the infrastructure already available to do
> this, it saves on code and debugging and review time.

I'll take the blame for this.  I recommended Narendra use the .test
method, as this is what I did back in 2005 in drivers/firmware/edd.c
which was one of the earliest consumers of the new sysfs code.  James
added the is_visible field to attribute groups in 2008, which I
missed (only 3 drivers make use of it, so it was easy to miss).  Since
that's the "new" preferred way to do it, we can adjust this patch
accordingly.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
