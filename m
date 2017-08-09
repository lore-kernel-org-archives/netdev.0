From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v9 1/4] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Wed, 9 Aug 2017 20:17:31 +0800
Message-ID: <d168687d-f849-4d09-1a2d-c9c6718b3318@huawei.com>
References: <1501917313-9812-1-git-send-email-dingtianhong@huawei.com>
 <1501917313-9812-2-git-send-email-dingtianhong@huawei.com>
 <20170808232200.GO16580@bhelgaas-glaptop.roam.corp.google.com>
 <MWHPR12MB1600249E96C320D5472F77ADC88B0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170809030236.GA7191@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "ashok.raj@intel.com" <ashok.raj@intel.com>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        Michael Werner <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "asit.k.mallick@intel.com" <asit.k.mallick@intel.com>,
        "patrick.j.cramer@intel.com" <patrick.j.cramer@intel.com>,
        "Suravee.Suthikulpanit@amd.com" <Suravee.Suthikulpanit@amd.com>,
        "Bob.Shaw@amd.com" <Bob.Shaw@amd.com>,
        "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
        "amira@mellanox.com" <amira@mellanox.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "David.Laight@aculab.com" <David.Laight@aculab.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "mark.rutland@arm.com" <mark.r
To: Bjorn Helgaas <helgaas@kernel.org>,
        Casey Leedom <leedom@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809030236.GA7191@bhelgaas-glaptop.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/8/9 11:02, Bjorn Helgaas wrote:
> On Wed, Aug 09, 2017 at 01:40:01AM +0000, Casey Leedom wrote:
>> | From: Bjorn Helgaas <helgaas@kernel.org>
>> | Sent: Tuesday, August 8, 2017 4:22 PM
>> | 
>> | This needs to include a link to the Intel spec
>> | (https://software.intel.com/sites/default/files/managed/9e/bc/64-ia-32-architectures-optimization-manual.pdf,
>> | sec 3.9.1).
>>
>>   In the commit message or as a comment?  Regardless, I agree.  It's always
>> nice to be able to go back and see what the official documentation says.
>> However, that said, links on the internet are ... fragile as time goes by,
>> so we might want to simply quote section 3.9.1 in the commit message since
>> it's relatively short:
>>
>>     3.9.1 Optimizing PCIe Performance for Accesses Toward Coherent Memory
>>           and Toward MMIO Regions (P2P)
>>
>>     In order to maximize performance for PCIe devices in the processors
>>     listed in Table 3-6 below, the soft- ware should determine whether the
>>     accesses are toward coherent memory (system memory) or toward MMIO
>>     regions (P2P access to other devices). If the access is toward MMIO
>>     region, then software can command HW to set the RO bit in the TLP
>>     header, as this would allow hardware to achieve maximum throughput for
>>     these types of accesses. For accesses toward coherent memory, software
>>     can command HW to clear the RO bit in the TLP header (no RO), as this
>>     would allow hardware to achieve maximum throughput for these types of
>>     accesses.
>>
>>     Table 3-6. Intel Processor CPU RP Device IDs for Processors Optimizing
>>                PCIe Performance
>>
>>     Processor                            CPU RP Device IDs
>>
>>     Intel Xeon processors based on       6F01H-6F0EH
>>     Broadwell microarchitecture
>>
>>     Intel Xeon processors based on       2F01H-2F0EH
>>     Haswell microarchitecture
> 
> Agreed, links are prone to being broken.  I would include in the
> changelog the complete title and order number, along with the link as
> a footnote.  Wouldn't hurt to quote the section too, since it's short.
> 

OK

>> | It should also include a pointer to the AMD erratum, if available, or
>> | at least some reference to how we know it doesn't obey the rules.
>>
>>   Getting an ACK from AMD seems like a forlorn cause at this point.  My
>> contact was Bob Shaw <Bob.Shaw@amd.com> and he stopped responding to me
>> messages almost a year ago saying that all of AMD's energies were being
>> redirected towards upcoming x86 products (likely Ryzen as we now know).  As
>> far as I can tell AMD has walked away from their A1100 (AKA "Seattle") ARM
>> SoC.
>>
>>   On the specific issue, I can certainly write up somthing even more
>> extensive than I wrote up for the comment in drivers/pci/quirks.c.  Please
>> review the comment I wrote up and tell me if you'd like something even more
>> detailed -- I'm usually acused of writing comments which are too long, so
>> this would be a new one on me ... :-)
> 
> If you have any bug reports with info about how you debugged it and
> concluded that Seattle is broken, you could include a link (probably
> in the changelog).  But if there isn't anything, there isn't anything.
> 
> I might reorganize those patches as:
> 
>   1) Add a PCI_DEV_FLAGS_RELAXED_ORDERING_BROKEN flag, the quirk that
>   sets it, and the current patch [2/4] that uses it.
> 
>   2) Add the Intel DECLARE_PCI_FIXUP_CLASS_EARLY()s with the Intel
>   details.
> 
>   3) Add the AMD DECLARE_PCI_FIXUP_CLASS_EARLY()s with the AMD
>   details.
> 

OK, I could reorganize it, but still need the Casey to give me the link
for the Seattle, otherwise I could remove the AMD part and wait until
someone show it. Thanks

Ding
> .
> 
