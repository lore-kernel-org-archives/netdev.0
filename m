From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 1/2] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Thu, 4 May 2017 21:01:24 +0000
Message-ID: <MWHPR12MB1600E78DD7F530AA9DC2433DC8EA0@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <cover.1493678834.git.leedom@chelsio.com>
 <758d0e431c732fe133e7b0e660bde5fc1beccdba.1493678834.git.leedom@chelsio.com>
 <CAKgT0UeuW88AHBX14H8xHteeG7vR0AH3apbjOeEDx_6p46x7tA@mail.gmail.com>
 <20170502165329.GB26406@linux.intel.com>
 <CAKgT0UcxjGCZu_QV-eF7_yWkDBbQpLpdaPqBf1gji8XXM5Cc=w@mail.gmail.com>
 <MWHPR12MB160095DF53CE981C923FE65DC8160@MWHPR12MB1600.namprd12.prod.outlook.com>,<CAKgT0UdJ17DGAphuP5Y9co6ky-GBFdq2s-1nqctY_Tz_iz5__g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "Raj, Ashok" <ashok.raj@intel.com>,
        Bjorn Helgaas <helgaas@kernel.org>,
        Michael Werner <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "Arjun V." <arjun@chelsio.com>,
        Asit K Mallick <asit.k.mallick@intel.com>,
        "Patrick J Cramer" <patrick.j.cramer@intel.com>,
        Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
        Bob Shaw <Bob.Shaw@amd.com>, h <l.stach@pengutronix.de>,
        Ding Tianhong <dingtianhong@huawei.com>,
        "Mark Rutland" <mark.rutland@arm.com>,
        Amir Ancel <amira@mellanox.com>,
        "Gabriele Paoloni" <gabriele.paoloni@huawei.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        LinuxArm <linuxarm@huawei.com>,
        David Laight <David.Laight@aculab.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Netdev <netdev@v
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0137.outbound.protection.outlook.com ([104.47.37.137]:43894
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752135AbdEDVB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 17:01:28 -0400
In-Reply-To: <CAKgT0UdJ17DGAphuP5Y9co6ky-GBFdq2s-1nqctY_Tz_iz5__g@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Alexander Duyck <alexander.duyck@gmail.com>
| Sent: Wednesday, May 3, 2017 9:02 AM
| ...
| It sounds like we are more or less in agreement. My only concern is
| really what we default this to. On x86 I would say we could probably
| default this to disabled for existing platforms since my understanding
| is that relaxed ordering doesn't provide much benefit on what is out
| there right now when performing DMA through the root complex. As far
| as peer-to-peer I would say we should probably look at enabling the
| ability to have Relaxed Ordering enabled for some channels but not
| others. In those cases the hardware needs to be smart enough to allow
| for you to indicate you want it disabled by default for most of your
| DMA channels, and then enabled for the select channels that are
| handling the peer-to-peer traffic.

  Yes, I think that we are mostly in agreement.  I had just wanted to make
sure that whatever scheme was developed would allow for simultaneously
supporting non-Relaxed Ordering for some PCIe End Points and Relaxed
Ordering for others within the same system.  I.e. not simply
enabling/disabling/etc.  based solely on System Platform Architecture.

  By the way, I've started our QA folks off looking at what things look lik=
e
in Linux Virtual Machines under different Hypervisors to see what
information they may provide to the VM in the way of what Root Complex Port
is being used, etc.  So far they've got Windows HyperV done and there
there's no PCIe Fabric exposed in any way: just the attached device.  I'll
have to see what pci_find_pcie_root_port() returns in that environment.
Maybe NULL?

  With your reservations (which I also share), I think that it probably
makes sense to have a per-architecture definition of the "Can I Use Relaxed
Ordering With TLPs Directed At This End Point" predicate, with the default
being "No" for any architecture which doesn't implement the predicate.  And
if the specified (struct pci_dev *) End Node is NULL, it ought to return
False for that as well.  I can't see any reason to pass in the Source End
Node but I may be missing something.

  At this point, this is pretty far outside my level of expertise.  I'm
happy to give it a go, but I'd be even happier if someone with a lot more
experience in the PCIe Infrastructure were to want to carry the ball
forward.  I'm not super familiar with the Linux Kernel "Rules Of
Engagement", so let me know what my next step should be.  Thanks.

Casey
