From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v9 2/4] PCI: Disable PCIe Relaxed Ordering if unsupported
Date: Wed, 9 Aug 2017 21:23:58 +0800
Message-ID: <a016e598-bcda-32bc-bfb1-4862550e6794@huawei.com>
References: <1501917313-9812-1-git-send-email-dingtianhong@huawei.com>
 <1501917313-9812-3-git-send-email-dingtianhong@huawei.com>
 <20170809022239.GP16580@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <leedom@chelsio.com>, <ashok.raj@intel.com>, <bhelgaas@google.com>,
        <werner@chelsio.com>, <ganeshgr@chelsio.com>,
        <asit.k.mallick@intel.com>, <patrick.j.cramer@intel.com>,
        <Suravee.Suthikulpanit@amd.com>, <Bob.Shaw@amd.com>,
        <l.stach@pengutronix.de>, <amira@mellanox.com>,
        <gabriele.paoloni@huawei.com>, <David.Laight@aculab.com>,
        <jeffrey.t.kirsher@intel.com>, <catalin.marinas@arm.com>,
        <will.deacon@arm.com>, <mark.rutland@arm.com>,
        <robin.murphy@arm.com>, <davem@davemloft.net>,
        <alexander.duyck@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>
To: Bjorn Helgaas <helgaas@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809022239.GP16580@bhelgaas-glaptop.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bjorn:

On 2017/8/9 10:22, Bjorn Helgaas wrote:
> On Sat, Aug 05, 2017 at 03:15:11PM +0800, Ding Tianhong wrote:
>> When bit4 is set in the PCIe Device Control register, it indicates
>> whether the device is permitted to use relaxed ordering.
>> On some platforms using relaxed ordering can have performance issues or
>> due to erratum can cause data-corruption. In such cases devices must avoid
>> using relaxed ordering.
>>
>> This patch checks if there is any node in the hierarchy that indicates that
>> using relaxed ordering is not safe. 
> 
> I think you only check the devices between the root port and the
> target device.  For example, you don't check siblings or cousins of
> the target device.
> 

OK, update the description.

>> In such cases the patch turns off the
>> relaxed ordering by clearing the eapability for this device.
> 
> s/eapability/capability/
> 
>> And if the
>> device is probably running in a guest machine, we should do nothing.
> 
> I don't know what this sentence means.  "Probably running in a guest
> machine" doesn't really make sense, and there's nothing in your patch
> that explicitly checks for being in a guest machine.
> 

Alex noticed that we should do nothing if in the virtual machine because
the Root Complex is NULL at that time, so I think this word should be more
clearly here.

>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Acked-by: Ashok Raj <ashok.raj@intel.com>
>> ---
>>  drivers/pci/pci.c   | 29 +++++++++++++++++++++++++++++
>>  drivers/pci/probe.c | 37 +++++++++++++++++++++++++++++++++++++
>>  include/linux/pci.h |  2 ++
>>  3 files changed, 68 insertions(+)
>>
>> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
>> index af0cc34..4f9d7c1 100644
>> --- a/drivers/pci/pci.c
>> +++ b/drivers/pci/pci.c
>> @@ -4854,6 +4854,35 @@ int pcie_set_mps(struct pci_dev *dev, int mps)
>>  EXPORT_SYMBOL(pcie_set_mps);
>>  
>>  /**
>> + * pcie_clear_relaxed_ordering - clear PCI Express relaxed ordering bit
>> + * @dev: PCI device to query
>> + *
>> + * If possible clear relaxed ordering
> 
> Why "If possible"?  The bit is required to be RW or hardwired to zero,
> so PCI_EXP_DEVCTL_RELAX_EN should *always* be zero when this returns.
> 

OK

>> + */
>> +int pcie_clear_relaxed_ordering(struct pci_dev *dev)
>> +{
...
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 
> .
> 
