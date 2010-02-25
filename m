From: "Domsch, Matt" <Matt_Domsch@Dell.com>
Subject: Re: [PATCH] Export smbios strings associated with onboard devices to
 sysfs
Date: Thu, 25 Feb 2010 15:46:23 -0600
Message-ID: <20100225214623.GD20147@mdomsch-pws380.aus.amer.dell.com>
References: <20100225202941.GA19404@mock.linuxdev.us.dell.com>
 <20100225214020.GA15010@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "K, Narendra" <Narendra_K@Dell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Shandilya, Sandeep K" <Sandeep_K_Shandilya@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>,
	"Iyer, Shyam" <Shyam_Iyer@Dell.com>
To: Alex Chiang <achiang@hp.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100225214020.GA15010@ldl.fc.hp.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 25, 2010 at 03:40:20PM -0600, Alex Chiang wrote:
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

I'm not sure I like the generic name.  Then the policy of which
provider (if there could be >1, which there will be once this can be
done via ACPI instead of static SMBIOS) gets to use that file name
becomes kernel-dependent, instead of userspace-dependent.

What is wrong with having both "smbiosname" and "acpiname" (for lack
of better names), either, both, or none, as files in the sysfs tree,
and let userspace set the policy of which one to use if there are >1 ?

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
