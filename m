From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH v7 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Wed, 26 Jul 2017 18:26:38 +0000
Message-ID: <MWHPR12MB1600065968964410EDFBDA3BC8B90@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1499955692-26556-1-git-send-email-dingtianhong@huawei.com>
        <1499955692-26556-3-git-send-email-dingtianhong@huawei.com>
        <e496ff1d-b836-ebef-fdf7-76273aaaaef6@codeaurora.org>
        <0260e398-bd8e-6615-6d5c-1f7c07b6fc09@huawei.com>
        <67be791f-e0cf-8284-9229-17174dc741ef@codeaurora.org>
        <5f9b8bfb-41a8-a17c-6fea-581aec1d5573@huawei.com>,<20170724090516.2e0f0d2a@w520.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Sinan Kaya <okaya@codeaurora.org>,
        "ashok.raj@intel.com" <ashok.raj@intel.com>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        "helgaas@kernel.org" <helgaas@kernel.org>,
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
        "catalin.marinas@arm.com" <catalin.marinas@arm.com
To: Alex Williamson <alex.williamson@redhat.com>,
        Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170724090516.2e0f0d2a@w520.home>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  By the way Ding, two issues:

 1. Did we ever get any acknowledgement from either Intel or AMD
    on this patch?  I know that we can't ensure that, but it sure would
    be nice since the PCI Quirks that we're putting in affect their
    products.

 2. I just realized that there's still a small hole in the patch with
    respect to PCIe SR-IOV Virtual Functions.  When the PCI Quirk
    notices a problematic PCIe Device and marks it to note that
    it's not "happy" receiving Transaction Layer Packets with the
    Relaxed Ordering Attribute set, it's my understanding that your
    current patch iterates down the PCIe Fabric and turns off the
    PCIe Capability Device Control[Relaxed Ordering Enable].
    But this scan may miss any SR-IOV VFs because they
    probably won't be instantiated at that time.  And, at a later
    time, when they are instantiated, they could well have their
    Relaxed Ordering Enable set.

    I think that the patch will need to be extended to modify
    drivers/pci.c/iov.c:sriov_enable() to explicitly turn off
    Relaxed Ordering Enable if the Root Complex is marked
    for no RO TLPs.

Casey=
