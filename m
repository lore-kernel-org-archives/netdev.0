From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH v7 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Thu, 27 Jul 2017 17:44:48 +0000
Message-ID: <MWHPR12MB1600556FFDCE3EC810D97591C8BE0@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1499955692-26556-1-git-send-email-dingtianhong@huawei.com>
 <1499955692-26556-3-git-send-email-dingtianhong@huawei.com>
 <e496ff1d-b836-ebef-fdf7-76273aaaaef6@codeaurora.org>
 <0260e398-bd8e-6615-6d5c-1f7c07b6fc09@huawei.com>
 <67be791f-e0cf-8284-9229-17174dc741ef@codeaurora.org>
 <5f9b8bfb-41a8-a17c-6fea-581aec1d5573@huawei.com>
 <20170724090516.2e0f0d2a@w520.home>
 <MWHPR12MB1600065968964410EDFBDA3BC8B90@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0UeAad6WArvrE71MFJywDs1wOnCF-iJRnbNLrL+knqhXeA@mail.gmail.com>
 <CAKgT0Uf5hdXUXja_jUB6_kBg6pyX8zXuOMOGzCVNgeBFMUsWqQ@mail.gmail.com>
 <CAKgT0Udn2vh6NaqZyiF69nXVnz2sT=e0ZgiDjWznhGZz-Gk+qQ@mail.gmail.com>
 <MWHPR12MB16007782C422082A92F4765DC8B90@MWHPR12MB1600.namprd12.prod.outlook.com>,<2feff1a5-25b7-eb6c-7628-7c2257c56e95@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Netdev <netdev@vger.kernel.org>,
        Bjorn Helgaas <helgaas@kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "David.Laight@aculab.com" <David.Laight@aculab.com>,
        "ashok.raj@intel.com" <ashok.raj@intel.com>,
        "Alex Williamson" <alex.williamson@redhat.com>,
        "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
        "Suravee.Suthikulpanit@amd.com" <Suravee.Suthikulpanit@amd.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        Sinan Kaya <okaya@codeaurora.org>,
        "robin.murphy@arm.com" <robin.murphy@arm.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Ganesh GR <g
To: Ding Tianhong <dingtianhong@huawei.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <2feff1a5-25b7-eb6c-7628-7c2257c56e95@huawei.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

| From: Ding Tianhong <dingtianhong@huawei.com>
| Sent: Wednesday, July 26, 2017 6:01 PM
|
| On 2017/7/27 3:05, Casey Leedom wrote:
| >
| > Ding, send me a note if you'd like me to work that [cxgb4vf patch] up
| > for you.
|
| Ok, you could send the change log and I could put it in the v8 version
| together, will you base on the patch 3/3 or build a independence patch?

Which ever you'd prefer.  It would basically mirror the same exact code tha=
t
you've got for cxgb4.  I.e. testing the setting of the VF's PCIe Capability
Device Control[Relaxed Ordering Enable], setting a new flag in
adpater->flags, testing that flag in cxgb4vf/sge.c:t4vf_sge_alloc_rxq().
But since the VF's PF will already have disabled the PF's Relaxed Ordering
Enable, the VF will also have it's Relaxed Ordering Enable disabled and any
effort by the internal chip to send TLPs with the Relaxed Ordering Attribut=
e
will be gated by the PCIe logic.  So it's not critical that this be in the
first patch.  Your call.  Let me know if you'd like me to send that to you.


| From: Ding Tianhong <dingtianhong@huawei.com>
| Sent: Wednesday, July 26, 2017 6:08 PM
|
| On 2017/7/27 2:26, Casey Leedom wrote:
| >
| >  1. Did we ever get any acknowledgement from either Intel or AMD
| >     on this patch?  I know that we can't ensure that, but it sure would
| >     be nice since the PCI Quirks that we're putting in affect their
| >     products.
|
| Still no Intel and AMD guys has ack this, this is what I am worried about=
,
| should I ping some man again ?

By amusing coincidence, Patrik Cramer (now Cc'ed) from Intel sent me a note
yesterday with a link to the official Intel performance tuning documentatio=
n
which covers this issue:

https://software.intel.com/sites/default/files/managed/9e/bc/64-ia-32-archi=
tectures-optimization-manual.pdf

In section 3.9.1 we have:

    3.9.1 Optimizing PCIe Performance for Accesses Toward Coherent Memory
          and Toward MMIO Regions (P2P)

    In order to maximize performance for PCIe devices in the processors
    listed in Table 3-6 below, the soft- ware should determine whether the
    accesses are toward coherent memory (system memory) or toward MMIO
    regions (P2P access to other devices). If the access is toward MMIO
    region, then software can command HW to set the RO bit in the TLP
    header, as this would allow hardware to achieve maximum throughput for
    these types of accesses. For accesses toward coherent memory, software
    can command HW to clear the RO bit in the TLP header (no RO), as this
    would allow hardware to achieve maximum throughput for these types of
    accesses.

    Table 3-6. Intel Processor CPU RP Device IDs for Processors Optimizing
               PCIe Performance

    Processor                            CPU RP Device IDs

    Intel Xeon processors based on       6F01H-6F0EH
    Broadwell microarchitecture

    Intel Xeon processors based on       2F01H-2F0EH
    Haswell microarchitecture

Unfortunately that's a pretty thin section.  But it does expand the set of
Intel Root Complexes for which our Linux PCI Quirk will need to cover.  So
you should add those to the next (and hopefully final) spin of your patch.
And, it also verifies the need to handle the use of Relaxed Ordering more
subtlely than simply turning it off since the NVMe peer-to-peer example I
keep bringing up would fall into the "need to use Relaxed Ordering" case ..=
.

It would have been nice to know why this is happening and if any future
processor would fix this.  After all, Relaxed Ordering, is just supposed to
be a hint.  At worst, a receiving device could just ignore the attribute
entirely.  Obviously someone made an effort to implement it but ... it
didn't go the way they wanted.

And, it also would have been nice to know if there was any hidden register
in these Intel Root Complexes which can completely turn off the effort to
pay attention to the Relaxed Ordering Attribute.  We've spend an enormous
amount of effort on this issue here on the Linux PCI email list struggling
mightily to come up with a way to determine when it's
safe/recommended/not-recommended/unsafe to use Relaxed Ordering when
directing TLPs towards the Root Complex.  And some architectures require RO
for decent performance so we can't just "turn it off" unilatterally.

Casey
