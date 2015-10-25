From: "Lan, Tianyu" <tianyu.lan@intel.com>
Subject: Re: [RFC Patch 05/12] IXGBE: Add new sysfs interface
	of "notify_vf"
Date: Sun, 25 Oct 2015 14:45:45 +0800
Message-ID: <562C7A99.3030101@intel.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
	<1445445464-5056-6-git-send-email-tianyu.lan@intel.com>
	<5627FB20.3020003@gmail.com> <562BA729.10903@intel.com>
	<562C7098.4030406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com, yang.z.zhang@intel.com,
	agraf@suse.de, kvm@vger.kernel.org, pbonzini@redhat.com,
	qemu-devel@nongnu.org, emil.s.tantilov@intel.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	netdev@vger.kernel.org, shannon.nelson@intel.com
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <562C7098.4030406@gmail.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org



On 10/25/2015 2:03 PM, Alexander Duyck wrote:
> On 10/24/2015 08:43 AM, Lan, Tianyu wrote:
>>
>> On 10/22/2015 4:52 AM, Alexander Duyck wrote:
>>> Also have you even considered the MSI-X configuration on the VF?  I
>>> haven't seen anything anywhere that would have migrated the VF's MSI-X
>>> configuration from BAR 3 on one system to the new system.
>>
>> MSI-X migration is done by Hypervisor(Qemu).
>> Following link is my Qemu patch to do that.
>> http://marc.info/?l=kvm&m=144544706530484&w=2
>
> I really don't like the idea of trying to migrate the MSI-X across from
> host to host while it is still active.  I really think Qemu shouldn't be
> moving this kind of data over in a migration.

Hi Alex:

VF MSI-X regs in the VM are faked by Qemu and Qemu maps host vectors of
VF with guest's vector. The MSIX data migrated are for faked regs rather
than the one on the host. After migration, Qemu will remap guest vectors
with host vectors on the new machine. Moreover, VM is stopped during
migrating MSI-X data.


>
> I think that having the VF do a suspend/resume is the best way to go.
> Then it simplifies things as all you have to deal with is the dirty page
> tracking for the Rx DMA and you should be able to do this without making
> things too difficult.
>

Yes, that will be simple and most concern is service down time. I will
test later.


> - Alex
