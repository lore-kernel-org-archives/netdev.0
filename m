From: Don Dutile <ddutile@redhat.com>
Subject: Re: Expose ltr/obff interface by sysfs
Date: Fri, 06 Apr 2012 17:20:21 -0400
Message-ID: <4F7F5E15.3040808@redhat.com>
References: <403610A45A2B5242BD291EDAE8B37D300FD0A434@SHSMSX102.ccr.corp.intel.com> <20120406082649.68fe5842@jbarnes-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Hao, Xudong" <xudong.hao@intel.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20120406082649.68fe5842@jbarnes-desktop>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/06/2012 11:26 AM, Jesse Barnes wrote:
> On Fri, 6 Apr 2012 02:43:59 +0000
> "Hao, Xudong"<xudong.hao@intel.com>  wrote:
>
>> Hi,
>>
>> I'm working on virtualization Xen/KVM. I saw there are ltr/obff enabling/disabling function in pci.c, but no called till now. I want to know if anybody(driver developer) are working for using it? Can driver change the LTR latency value dynamically?
>
> I believe the value is writable, but I'd expect some devices to
> misbehave if the value were programmed too high.  Performance would
> also suffer if the value were set too high, at least for IOPS sensitive
> devices.
>
>> /*
>> LTR(Latency tolerance reporting) allows devices to send messages to the root complex indicating their latency tolerance for snooped&  unsnooped memory transactions.
>> OBFF (optimized buffer flush/fill), where supported, can help improve energy efficiency by giving devices information about when interrupts and other activity will have a reduced power impact.
>> */
>>
>> One way to control ltr/obff is used by driver, however, I'm considering that in virtualization, how guest OS driver control them. I have an idea that expose an inode interface by sysfs, like "reset" inode implemented in pci-sysfs.c, so that system user/administrator can enable/disable ltr/obff or set latency value on userspace, but not limited on driver. Comments?
>
> Given how device specific these extensions are, I'd expect you'd need
> to know about each specific device anyway, which is why I think the
> control belongs in the driver.  I don't see why you'd need to
> enable/disable/change these functions when assigning a device from one
> guest to another...
>

and looking at this code last week, I noticed the ltr, obff & ido
functions should be doing pcie_cap_has_*() checks before
accessing registers that may not exist, as is done in
pci_[save,restore]_pcie_state() ...

in drivers/pci/pci.c:
#define pcie_cap_has_devctl2(type, flags)               \
                 ((flags & PCI_EXP_FLAGS_VERS) > 1)
#define pcie_cap_has_lnkctl2(type, flags)               \
                 ((flags & PCI_EXP_FLAGS_VERS) > 1)
#define pcie_cap_has_sltctl2(type, flags)               \
                 ((flags & PCI_EXP_FLAGS_VERS) > 1)
