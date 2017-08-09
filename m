From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH v9 1/4] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Wed, 9 Aug 2017 16:46:07 +0000
Message-ID: <MWHPR12MB1600E9D94E74E1DECC192097C88B0@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1501917313-9812-1-git-send-email-dingtianhong@huawei.com>
 <1501917313-9812-2-git-send-email-dingtianhong@huawei.com>
 <20170808232200.GO16580@bhelgaas-glaptop.roam.corp.google.com>,<20170809155841.GA8675@otc-nc-03>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Ding Tianhong <dingtianhong@huawei.com>,
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
        "mark.rutland@arm.com" <mark.rutla
To: "Raj, Ashok" <ashok.raj@intel.com>,
        Bjorn Helgaas <helgaas@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170809155841.GA8675@otc-nc-03>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

| From: Raj, Ashok <ashok.raj@intel.com>
| Sent: Wednesday, August 9, 2017 8:58 AM
| ...
| As Casey pointed out in an earlier thread, we choose the heavy hammer
| approach because there are some that can lead to data-corruption as oppos=
ed
| to perf degradation.

Careful.  As far as I'm aware, there is no Data Corruption problem
whatsoever with Intel Root Ports and processing of Transaction Layer Packet=
s
with and without the Relaxed Ordering Attribute set.

The only issue which we've discovered with relatively recent Intel Root Por=
t
implementations and the use of the Relaxed Ordering Attribute is a
performance issue.  To the best of our ability to analyze the PCIe traces,
it appeared that the Intel Root Complex delayed returning Link Flow Control
Credits resulting in lowered performance (total bandwidth).  When we used
Relaxed Ordering for Ingress Packet Data delivery on a 100Gb/s Ethernet
link with 1500-byte MTU, we were pegged at ~75Gb/s.  Once we disabled
Relaxed Ordering, we were able to deliver Ingress Packet Data to Host Memor=
y
at the full link rate.

Casey
