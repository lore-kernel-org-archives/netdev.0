From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Use firmware provided index to register a network
 interface
Date: Thu, 23 Sep 2010 08:27:30 -0700
Message-ID: <20100923152730.GA1261@kroah.com>
References: <20100922183137.GA7607@auslistsprd01.us.dell.com>
 <20100922192228.GB29899@kroah.com>
 <EDA0A4495861324DA2618B4C45DCB3EE6A0AF8@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, Matt_Domsch@Dell.com,
	Charles_Rose@Dell.com, Jordan_Hargrave@Dell.com,
	Vijay_Nijhawan@Dell.com
To: Narendra_K@Dell.com
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE6A0AF8@blrx3m08.blr.amer.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 23, 2010 at 08:40:44PM +0530, Narendra_K@Dell.com wrote:
> > -----Original Message-----
> > From: Greg KH [mailto:greg@kroah.com]
> > Sent: Thursday, September 23, 2010 12:52 AM
> > To: K, Narendra
> > Cc: netdev@vger.kernel.org; linux-hotplug@vger.kernel.org; linux-
> > pci@vger.kernel.org; Domsch, Matt; Rose, Charles; Hargrave, Jordan;
> > Nijhawan, Vijay
> > Subject: Re: [PATCH] Use firmware provided index to register a network
> > interface
> > 
> > On Wed, Sep 22, 2010 at 01:31:38PM -0500, Narendra K wrote:
> > > Hello,
> > >
> > > Here is another approach to address the issue of "eth0 does not
> > always
> > > map to the Integrated NIC Port 1 as denoted on server chassis
> label".
> > > For more details please refer to the thread -
> > > http://marc.info/?l=linux-netdev&m=128163454631618&w=3.
> > >
> > > Patch makes use of the firmware provided index to derive ethN names.
> > > That way the naming scheme adheres to the existing requirements of
> > > ethN namespace and with IFNAMSIZ length.
> > 
> > Ick, again, what's wrong with using udev for this as it is designed
> to?
> > That way no kernel changes are needed, and no one has to rely on the
> > BIOS getting the firmware number right (meaning it will work on all
> > types of systems.)
> > 
> 
> 1. We tried addressing this issue using udev only and without any kernel
> changes, during Nov-Dec 2008 timeframe using Biosdevname udev helper
> utility. Biosdevname utility has the ability to suggest BIOS intended
> name of an interface given its OS name.
> 
> /sbin/biosdevname -I eth2 - (OS name)
> eth0 - (Name according to the BIOS)
> 
> KERNEL!="eth*", GOTO="biosdevname_end"
> ACTION!="add",  GOTO="biosdevname_end"
> NAME=="?*",     GOTO="biosdevname_end"
> 
> PROGRAM="/sbin/biosdevname --policy=all_ethN -i %k",
> ENV{INTERFACE_NAME}="%c"
> 
> LABEL="biosdevname_end"
> 
> We observed that renames in the same namespace, which is ethN namespace,
> resulted in interface names like eth_rename_ren. The solution was
> susceptible to driver load order. Please refer to this bug report-
> https://bugzilla.novell.com/show_bug.cgi?id=441079.
> 
> This solution was not favored.

That's because for some reason you don't want to accept the fact that if
you want to rename things in a persistant manner, you have to do so in a
namespace that is outside of the kernel's normal one.

Now trying to change the kernel namespace itself seems like a bad hack
around this fact.

thanks,

greg k-h
