From: Narendra K <Narendra_K@dell.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Mon, 12 Oct 2009 13:47:12 -0500
Message-ID: <20091012184711.GA4836@mock.linuxdev.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE589541@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matt_domsch@dell.com, netdev@vger.kernel.org,
	shemminger@vyatta.com, linux-hotplug@vger.kernel.org,
	jordan_hargrave@dell.com, charles_rose@dell.com
To: greg@kroah.com, notting@redhat.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE589541@blrx3m08.blr.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Mon, Oct 12, 2009 at 01:45:28PM -0400, Bill Nottingham wrote:
> > Greg KH (greg@kroah.com) said: 
> > > > Today, port naming is completely nondeterministic.  If you have 
> > > > but one NIC, there are few chances to get the name wrong (it'll be
> eth0).
> > > > If you have >1 NIC, chances increase to get it wrong.
> > > 
> > > That is why all distros name network devices based on the only 
> > > deterministic thing they have today, the MAC address.  I still fail 
> > > to see why you do not like this solution, it is honestly the only 
> > > way to properly name network devices in a sane manner.
> > > 
> > > All distros also provide a way to easily rename the network devices,
> 
> > > to place a specific name on a specific MAC address, so again, this 
> > > should all be solved already.
> > 
> > No, it's not solved. Even if you have persistent names once you 
> > install, if you ever re-image, you're likely to get *different* 
> > persistent names; the first load will always be non-detmerministic.
> > 
> > The only way around this would be to have some sort of screen like:
> > 
> >   Would you like your network devices to be enumerated by
> > 
> >   [ ] MAC address
> >   [ ] PCI device order
> >   [ ] Driver name
> >   [ ] Other
> 
> [ ] PCI slot name
> 
> That's one that modern systems are now reporting, and should solve
> Matt's problem as well, right?

MAC address and pci slots might ensure that device names are persistant
across system reboots. They do not assure that the LOM 1 is named as
"eth0" which is the expectation. In case of unattended installs,
installers abort installation if the port which gets the name "eth0"
does not have the link up and doesn't have the IP.This is often the case
becaused the LOMS have the boot capability. We can acheive
persistent naming using MAC adresses. But it doesn't address the
expectation that LOM-1 becomes "eth0" on every reboot which is mostly
used for unattended installs.(Installers can be told to use options like
IPAPPEND 2, but the this solution would make it of no use).

> > which is just all sorts of fail in and of itself. Especially since 
> > once you get to the point where you can coherently ask this in a 
> > native installer, the drivers have already loaded.
> 
> No, the driver load order doesn't determine this, you need the drivers
> loaded first before you can rename anything :)
> 

Renaming an interface in the kernel namespace itself, might need to
problems like duplicate names. But having names in alternate namespace not in kernel
namespace might be more useful.


> And I don't see how Matt's proposed patch helps resolve this type of
> issue any better than what we currently have today, do you?
> 

I have a system which has 4 LOMS and 1 add-in NIC and the add-in NIC
always gets the name "eth0" eventhough i PXE booted from LOM-1. Since
"eth0" doesn't have link up, the installer stops and asks which
interface should get IP. This would not suit an unattended install
scenario. If the installer can use a pathname like
/dev/net/by-chassis-label/Embedded_NIC_1 (->eth1 which is my LOM-1), it
would always point to the correct interface irrespective of whether it
is "eth0" or not.

With regards,
Narendra K
