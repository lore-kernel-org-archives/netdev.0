From: <Narendra_K@Dell.com>
Subject: RE: [PATCH] Export smbios strings associated with onboard devicesto sysfs
Date: Tue, 2 Mar 2010 23:12:07 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE6122A3@blrx3m08.blr.amer.dell.com>
References: <20100225202941.GA19404@mock.linuxdev.us.dell.com> <20100225214020.GA15010@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <Matt_Domsch@Dell.com>,
	<Jordan_Hargrave@Dell.com>, <Sandeep_K_Shandilya@Dell.com>,
	<Charles_Rose@Dell.com>, <Shyam_Iyer@Dell.com>
To: <achiang@hp.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20100225214020.GA15010@ldl.fc.hp.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Alex Chiang [mailto:achiang@hp.com]
> Sent: Friday, February 26, 2010 3:10 AM
> To: K, Narendra
> Cc: netdev@vger.kernel.org; linux-hotplug@vger.kernel.org; linux-
> pci@vger.kernel.org; Domsch, Matt; Hargrave, Jordan; Shandilya,
Sandeep
> K; Rose, Charles; Iyer, Shyam
> Subject: Re: [PATCH] Export smbios strings associated with onboard
> devicesto sysfs
> 
> * Narendra K <Narendra_K@dell.com>:
> >
> > * We have been having discussions in the netdev list about
> > creating multiple names for the network interfaces to bring
> > determinism into the way network interfaces are named in the
> > OSes. In specific, "eth0 in the OS does not always map to the
> > integrated NIC Gb1 as labelled on the chassis".
> 
> Yes, I agree that this is a real problem that we do not handle
> well today.
> 
> > 1.Export smbios strings of onboard devices, to sysfs. For example -
> >
> > cat /sys/class/net/eth0/device/smbiosname
> > Embedded NIC 2
> >
> > cat  /sys/bus/pci/devices/0000\:03\:00.0/smbiosname
> > Embedded NIC 2
> 
> I agree with this concept, but I don't like the interface.
> 
> The name "smbiosname" isn't the proper level of abstraction. We
> don't want users to care what firmware standard is providing the
> name (think smbios vs acpi vs open firmware...).
> 
> We learned this lesson with exposing ACPI interfaces. Let's not
> make the same mistake here.
> 
> Something like "firmwarename", "fwname", "platformname" etc. is
> generic, and then the interface will make sense for platforms
> that do not implement SMBIOS.
> 
> I don't particularly care which name you choose as long as it's
> properly generic.
> 
> As far as implementation goes, I've been thinking about this
> problem for a while now, and I keep wanting to use the
> pci_create_slot() API, but am still a little on the fence about
> it.
> 
> The pros:
> 	- all you have to do is write a simple little driver that
> 	  can read SMBIOS to get PCI bus:devfn and the name, and
> 	  then you call pci_create_slot(). Then you get all sorts
> 	  of stuff for free, like sysfs exposure, proper
> 	  refcounting (important given that the PCI logical
> 	  hotplug interface (/sys/bus/pci/rescan and friends) can
> 	  be used to remove onboard devices), etc.
> 
> 	- see drivers/acpi/pci_slot.c for an example of how to
> 	  detect slots and then register them.
> 
> The cons:
> 	- the user interface is /sys/bus/pci/slots/<name>
> 
> 	I don't know if that is an appropriate interface, since
> 	technically an onboard device isn't in a slot. But maybe
> 	if you did something like:
> 
> 		/sys/bus/pci/slots/onboard0
> 		/sys/bus/pci/slots/onboard1
> 
> 	that might make sense.
> 
> 	Or...
> 		/sys/bus/pci/onboard/<name>
> 
> I read through the patch, but given that the implementation
> strategy might change based on my comments, will hold off and see
> how the conversation develops.

Thanks. I will wait too, to see how the discussion develops on this
method of implementation.

With regards,
Narendra K
