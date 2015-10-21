From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [RFC Patch 00/12] IXGBE: Add live migration support for SRIOV NIC
Date: Wed, 21 Oct 2015 21:45:42 +0300
Message-ID: <CAJ3xEMiStMJdGjgO9=MQrhLpBo8ZiTRoOL_P=aC9kyrNi91FSw@mail.gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhelgaas@google.com, carolyn.wyborny@intel.com,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	eddie.dong@intel.com, nrupal.jani@intel.com,
	yang.z.zhang@intel.com, agraf@suse.de, kvm@vger.kernel.org,
	Paolo Bonzini <pbonzini@redhat.com>, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	john.ronciak@intel.com,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Shannon Nelson <shannon.nelson@intel.com>
To: Lan Tianyu <tianyu.lan@intel.com>,
	"Michael S. Tsirkin <mst@redhat.com> (mst@redhat.com)"
	<mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 21, 2015 at 7:37 PM, Lan Tianyu <tianyu.lan@intel.com> wrote:
> This patchset is to propose a new solution to add live migration support
> for 82599 SRIOV network card.

> In our solution, we prefer to put all device specific operation into VF and
> PF driver and make code in the Qemu more general.

[...]

> Service down time test
> So far, we tested migration between two laptops with 82599 nic which
> are connected to a gigabit switch. Ping VF in the 0.001s interval
> during migration on the host of source side. It service down
> time is about 180ms.

So... what would you expect service down wise for the following
solution which is zero touch and I think should work for any VF
driver:

on host A: unplug the VM and conduct live migration to host B ala the
no-SRIOV case.

on host B:

when the VM "gets back to live", probe a VF there with the same assigned mac

next, udev on the VM will call the VF driver to create netdev instance

DHCP client would run to get the same IP address

+ under config directive (or from Qemu) send Gratuitous ARP to notify
the switch/es on the new location for that mac.

Or.
