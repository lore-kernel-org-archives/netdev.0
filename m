From: Alex Chiang <achiang@hp.com>
Subject: Re: [PATCH] Export smbios strings associated with onboard devices
	to sysfs
Date: Thu, 25 Feb 2010 15:20:03 -0700
Message-ID: <20100225222003.GE19056@ldl.fc.hp.com>
References: <20100225202941.GA19404@mock.linuxdev.us.dell.com> <20100225214020.GA15010@ldl.fc.hp.com> <20100225214623.GD20147@mdomsch-pws380.aus.amer.dell.com>
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
To: "Domsch, Matt" <Matt_Domsch@Dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100225214623.GD20147@mdomsch-pws380.aus.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Domsch, Matt <Matt_Domsch@Dell.com>:
> On Thu, Feb 25, 2010 at 03:40:20PM -0600, Alex Chiang wrote:
> > 
> > I agree with this concept, but I don't like the interface.
> > 
> > The name "smbiosname" isn't the proper level of abstraction. We
> > don't want users to care what firmware standard is providing the
> > name (think smbios vs acpi vs open firmware...).
> > 
> > We learned this lesson with exposing ACPI interfaces. Let's not
> > make the same mistake here.
> > 
> > Something like "firmwarename", "fwname", "platformname" etc. is
> > generic, and then the interface will make sense for platforms
> > that do not implement SMBIOS.
> > 
> > I don't particularly care which name you choose as long as it's
> > properly generic.
> 
> I'm not sure I like the generic name.  Then the policy of which
> provider (if there could be >1, which there will be once this can be
> done via ACPI instead of static SMBIOS) gets to use that file name
> becomes kernel-dependent, instead of userspace-dependent.
 
I would imagine that an ACPI _DSM would take precedence over
SMBIOS in that example.

The kernel implements policy like that today already, especially
in the hotplug drivers.

If you modprobe pci_slot, it creates files named with ACPI _SUN.
If you then load pciehp, the names from PCI config space take
precedence.

> What is wrong with having both "smbiosname" and "acpiname" (for lack
> of better names), either, both, or none, as files in the sysfs tree,
> and let userspace set the policy of which one to use if there are >1 ?

sysfs is already confusing enough as it is.

If we present multiple names, every piece of software has to
choose which one to use. Not everyone will simply look at what 
udev creates.

And those will be a maintenance burden forever.

If we have a generic name, then all the non-x86 platforms that do
not have SMBIOS nor ACPI can benefit. In the x86/ia64 world, we
also protect ourselves from new, future firmware standards.

ACPI has been trying to dig itself out of this hole for a long
time, and they're probably stuck with legacy interfaces forever.
I'm hoping not to make the same mistake again.

Thanks,
/ac

