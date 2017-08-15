From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v10 3/5] PCI: Disable Relaxed Ordering Attributes for AMD
 A1100
Date: Tue, 15 Aug 2017 09:40:27 +0800
Message-ID: <f918dd35-a317-d745-974c-bd271136bf41@huawei.com>
References: <1502725499-11276-1-git-send-email-dingtianhong@huawei.com>
 <1502725499-11276-4-git-send-email-dingtianhong@huawei.com>
 <20170814171937.GA52656@otc-nc-03>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <leedom@chelsio.com>, <bhelgaas@google.com>, <helgaas@kernel.org>,
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
To: "Raj, Ashok" <ashok.raj@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814171937.GA52656@otc-nc-03>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/8/15 1:19, Raj, Ashok wrote:
> On Mon, Aug 14, 2017 at 11:44:57PM +0800, Ding Tianhong wrote:
>> Casey reported that the AMD ARM A1100 SoC has a bug in its PCIe
>> Root Port where Upstream Transaction Layer Packets with the Relaxed
>> Ordering Attribute clear are allowed to bypass earlier TLPs with
>> Relaxed Ordering set, it would cause Data Corruption, so we need
>> to disable Relaxed Ordering Attribute when Upstream TLPs to the
>> Root Port.
>>
>> Signed-off-by: Casey Leedom <leedom@chelsio.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Acked-by: Ashok Raj <ashok.raj@intel.com>
> 
> I can't ack this patch :-).. must be someone from AMD. Please remove my
> signature from this.
> 

Sorry for funny mistake :)  I will fix it.

Ding

>> ---
>>  drivers/pci/quirks.c | 16 ++++++++++++++++
>>  1 file changed, 16 insertions(+)
>>
>> diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
>> index 1272f7e..1407604 100644
>> --- a/drivers/pci/quirks.c
>> +++ b/drivers/pci/quirks.c
>> @@ -4089,6 +4089,22 @@ static void quirk_relaxedordering_disable(struct pci_dev *dev)
>>  			      quirk_relaxedordering_disable);
>>  
>>  /*
>> + * The AMD ARM A1100 (AKA "SEATTLE") SoC has a bug in its PCIe Root Complex
>> + * where Upstream Transaction Layer Packets with the Relaxed Ordering
>> + * Attribute clear are allowed to bypass earlier TLPs with Relaxed Ordering
>> + * set.  This is a violation of the PCIe 3.0 Transaction Ordering Rules
>> + * outlined in Section 2.4.1 (PCI Express(r) Base Specification Revision 3.0
>> + * November 10, 2010).  As a result, on this platform we can't use Relaxed
>> + * Ordering for Upstream TLPs.
>> + */
>> +DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_AMD, 0x1a00, PCI_CLASS_NOT_DEFINED, 8,
>> +			      quirk_relaxedordering_disable);
>> +DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_AMD, 0x1a01, PCI_CLASS_NOT_DEFINED, 8,
>> +			      quirk_relaxedordering_disable);
>> +DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_AMD, 0x1a02, PCI_CLASS_NOT_DEFINED, 8,
>> +			      quirk_relaxedordering_disable);
>> +
>> +/*
>>   * Per PCIe r3.0, sec 2.2.9, "Completion headers must supply the same
>>   * values for the Attribute as were supplied in the header of the
>>   * corresponding Request, except as explicitly allowed when IDO is used."
>> -- 
>> 1.8.3.1
>>
>>
> 
> .
> 
