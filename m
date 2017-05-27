From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 1/2] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Sat, 27 May 2017 18:34:09 +0800
Message-ID: <c71a27ba-4630-906b-e022-a12c44717730@huawei.com>
References: <cover.1493678834.git.leedom@chelsio.com>
 <758d0e431c732fe133e7b0e660bde5fc1beccdba.1493678834.git.leedom@chelsio.com>
 <CAKgT0UeuW88AHBX14H8xHteeG7vR0AH3apbjOeEDx_6p46x7tA@mail.gmail.com>
 <20170502165329.GB26406@linux.intel.com>
 <CAKgT0UcxjGCZu_QV-eF7_yWkDBbQpLpdaPqBf1gji8XXM5Cc=w@mail.gmail.com>
 <MWHPR12MB160095DF53CE981C923FE65DC8160@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0UdJ17DGAphuP5Y9co6ky-GBFdq2s-1nqctY_Tz_iz5__g@mail.gmail.com>
 <MWHPR12MB1600E78DD7F530AA9DC2433DC8EA0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0Ucwkp+fi-9HhMbze6t_i15dj4e2WQBp13Coi6MegrDh=w@mail.gmail.com>
 <22c46382-5778-022f-d0bd-74abec9e9c7c@huawei.com>
 <CAKgT0Ufg6uebqj79e1FOHoPpF-GxPYMkp353r3Ok_=nM8wF6qA@mail.gmail.com>
 <MWHPR12MB1600AC957C7E3B0DB4F06D6CC8EE0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <2eab1a1d-3444-fe11-7626-5b6459e954f8@huawei.com>
 <CAKgT0UfwnGEf2yok5E2KeZPP2JkqhTpCf+25+A8j5jfupLRJ5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
 Gabriele Paoloni <gabriele.paoloni@huawei.com>, Asit K
 Mallick <asit.k.mallick@intel.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>, LinuxArm <linuxarm@huawei.com>, "Raj,
 Ashok" <ashok.raj@intel.com>, Bjorn Helgaas <helgaas@kernel.org>,
 Ganesh GR <ganeshgr@chelsio.com>, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
 Bob Shaw <Bob.Shaw@amd.com>, Casey Leedom <leedom@chelsio.com>,
 Patrick J Cramer <patrick.j.cramer@intel.com>, "Arjun V." <arjun@chelsio.com>,
 Michael Werner <werner@chelsio.com>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 Amir Ancel <amira@mellanox.com>, Netdev <netdev@vger.kernel.org>,
 David Laight <David.Laight@aculab.com>,
 Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
 Robin Murphy <robin.murphy@arm.com>, David Miller <davem@davemloft.net>,
 h
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAKgT0UfwnGEf2yok5E2KeZPP2JkqhTpCf+25+A8j5jfupLRJ5A@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org



On 2017/5/26 3:49, Alexander Duyck wrote:
> On Thu, May 25, 2017 at 6:35 AM, Ding Tianhong <dingtianhong@huawei.com> wrote:
>>
>> On 2017/5/9 8:48, Casey Leedom wrote:
>>>
>>> | From: Alexander Duyck <alexander.duyck@gmail.com>
>>> | Date: Saturday, May 6, 2017 11:07 AM
>>> |
>>> | | From: Ding Tianhong <dingtianhong@huawei.com>
>>> | | Date: Fri, May 5, 2017 at 8:08 PM
>>> | |
>>> | | According the suggestion, I could only think of this code:
>>> | | ..
>>> |
>>> | This is a bit simplistic but it is a start.
>>>
>>>   Yes, something tells me that this is going to be more complicated than any
>>> of us like ...
>>>
>>> | The other bit I was getting at is that we need to update the core PCIe
>>> | code so that when we configure devices and the root complex reports no
>>> | support for relaxed ordering it should be clearing the relaxed
>>> | ordering bits in the PCIe configuration registers on the upstream
>>> | facing devices.
>>>
>>>   Of course, this can be written to by the Driver at any time ... and is in
>>> the case of the cxgb4 Driver ...
>>>
>>>   After a lot of rummaging around, it does look like KVM prohibits writes to
>>> the PCIe Capability Device Control register in drivers/xen/xen-pciback/
>>> conf_space_capability.c and conf_space.c simply because writes aren't
>>> allowed unless "permissive" is set.  So it ~looks~ like a driver running in
>>> a Virtual Machine can't turn Enable Relaxed Ordering back on ...
>>>
>>> | The last bit we need in all this is a way to allow for setups where
>>> | peer-to-peer wants to perform relaxed ordering but for writes to the
>>> | host we have to not use relaxed ordering. For that we need to enable a
>>> | special case and that isn't handled right now in any of the solutions
>>> | we have coded up so far.
>>>
>>>   Yes, we do need this.
>>>
>>>
>>> | From: Alexander Duyck <alexander.duyck@gmail.com>
>>> | Date: Saturday, May 8, 2017 08:22 AM
>>> |
>>> | The problem is we need to have something that can be communicated
>>> | through a VM. Your change doesn't work in that regard. That was why I
>>> | suggested just updating the code so that we when we initialized PCIe
>>> | devices what we do is either set or clear the relaxed ordering bit in
>>> | the PCIe device control register. That way when we direct assign an
>>> | interface it could know just based on the bits int the PCIe
>>> | configuration if it could use relaxed ordering or not.
>>> |
>>> | At that point the driver code itself becomes very simple since you
>>> | could just enable the relaxed ordering by default in the igb/ixgbe
>>> | driver and if the bit is set or cleared in the PCIe configuration then
>>> | we are either sending with relaxed ordering requests or not and don't
>>> | have to try and locate the root complex.
>>> |
>>> | So from the sound of it Casey has a special use case where he doesn't
>>> | want to send relaxed ordering frames to the root complex, but instead
>>> | would like to send them to another PCIe device. To do that he needs to
>>> | have a way to enable the relaxed ordering bit in the PCIe
>>> | configuration but then not send any to the root complex. Odds are that
>>> | is something he might be able to just implement in the driver, but is
>>> | something that may become a more general case in the future. I don't
>>> | see our change here impacting it as long as we keep the solution
>>> | generic and mostly confined to when we instantiate the devices as the
>>> | driver could likely make the decision to change the behavior later.
>>>
>>>   It's not just me.  Intel has said that while RO directed at the Root
>>> Complex Host Coherent Memory has a performance bug (not Data Corruption),
>>> it's a performance win for Peer-to-Peer writes to MMIO Space.  (I'll be very
>>> interested in hearing what the bug is if we get that much detail.  The very
>>> same TLPs directed to the Root Complex Port without Relaxed Ordering set get
>>> good performance.  So this is essentially a bug in the hardware that was
>>> ~trying~ to implement a performance win.)
>>>
>>>   Meanwhile, I currently only know of a single PCIe End Point which causes
>>> catastrophic results: the AMD A1100 ARM SoC ("SEATTLE").  And it's not even
>>> clear that product is even alive anymore since I haven't been able to get
>>> any responses from them for several months.
>>>
>>>   What I'm saying is: let's try to architect a solution which doesn't throw
>>> the baby out with the bath water ...
>>>
>>>   I think that if a Device's Root Complex Port has problems with Relaxed
>>> Ordering, it ~probably~ makes sense to turn off the PCIe Capability Device
>>> Control[Enable Relaxed Ordering] when we assign a device to a Virtual
>>> Machine since the Device Driver can no longer query the Relaxed Ordering
>>> Support of the Root Complex Port.  The only down side of this would be if we
>>> assigned two Peers to a VM in an application which wanted to do Peer-to-Peer
>>> transfers.  But that seems like a hard application to support in any case
>>> since the PCI Bus:Slot.Function IDs for assigned Devices within a VM don't
>>> match the actual values.
>>>
>>>   For Devices running in the base OS/Hypervisor, their Drivers can query the
>>> Relaxed Ordering Support for the Root Complex Port or a Peer Device.  So a
>>> simple flag within the (struct pci_dev *)->dev_flags would serve for that
>>> along with a per-Architecture/Platform mechanism for setting it ...
>>>
>>> Casey
>>>
>>
>> I have take a time to talk to our kvm team about how to distinguish the relaxed
>> ordering in the VM for some vf just like 82599-vf, the probe routine looks like
>> could work like this:
>> 1) QEMU could emulate the platform by the Vender ID and device ID which could be
>>    read from the host.
>> 2) The QEMU could create a virtual PCIe dev complex and recognize the PCIe bus address which
>>    come and detach from the host to the guest.
>> 3) the PCI quirk could enable the Relaxed Ordering by the Vendor ID and Device ID.
>> 4) The VF drivers could read the flag and set to the hw.
>>
>> So I think we could set the PCI_DEV_FLAGS_RELAXED_ORDERING_ENABLED for some special platform
>> and don't enable by default, if I miss something, please not hesitate to enlighten me :)
> 
> This isn't what I had in mind at all.
> 
> So what Casey had originally submitted was a step in the direction of
> what I was thinking. Basically on platforms where it is not advisable
> to enable relaxed ordering we need to advertise that relaxed ordering
> is not safe. Then when we are initializing the devices underneath
> those we need to be clearing the relaxed ordering enable bits in the
> PCI configuration, that is the piece that was missing from Casey's
> original patch. In addition we then need to have a way for devices to
> optionally enable relaxed ordering for cases like Casey pointed out
> where they might want to use relaxed ordering for peer-to-peer
> transactions, but not for transactions to the root complex. Finally in
> the case of the Intel drivers we could then just drop the compile time
> checks entirely and just enable the device to configure the internal
> registers for relaxed ordering because the configuration space becomes
> the spot that controls if this gets enabled or not.
> 
> So the initial set of patches Casey submitted only really consisted of
> 2 patches. What I am proposing is that we would be looking at
> expanding this out to about 4 patches. The first patch is the original
> 1 of 2, the second patch would be to modify the PCI initialization
> code to clear the relaxed ordering enable bit in the event that the
> root complex doesn't want relaxed ordering enabled, the third would be
> to make changes to the Chelsio driver as needed to allow for the
> peer-to-peer case to be enabled when the relaxed ordering bit in the
> configuration space is not enabled without triggering any relaxed
> ordering requests to the root complex, and the last one would be to
> drop the defines in ixgbe and whatever other Intel drivers are
> currently checking for either SPARC or the define that was added to
> support relaxed ordering and just act like we are going to do it
> always with the PCI configuration space controlling if we do or not.
> 
> Ideally as a part of the second patch we should have a way of testing
> if a given path can support relaxed ordering. That way when we go to
> try to enable a peer-to-peer setup we can be certain that a given path
> will work and don't try enabling it in paths that would be unsupported
> for peer-to-peer.
> 
> This ends up being somewhat of a risk for the Intel NICs, but if the
> Chelsio devices have been running with relaxed ordering enabled for
> some time and have identified the chipsets that should be issues, then
> odds are we should be fine as well.
> 
According to your opinion, I try to build the second patch again,
1. in the pcie probe time, the pci_configure_relaxed_ordering will used to set the relaxed ordering
bit for configuration space.
2. export the pcie_get_relaxed_ordering for drivers and the drivers could decide whether should enable the relaxed ordering.

If I still go to the wrong path, please correct me, thanks.

---------------------------------------------------------------
diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index b01bd5b..0076e4a 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -4852,6 +4852,28 @@ int pcie_get_mps(struct pci_dev *dev)
 }
 EXPORT_SYMBOL(pcie_get_mps);

+int pcie_set_relaxed_ordering(struct pci_dev *dev)
+{
+ return pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_RELAX_EN);
+}
+EXPORT_SYMBOL(pcie_set_relaxed_ordering);
+
+int pcie_clear_relaxed_ordering(struct pci_dev *dev)
+{
+ return pcie_capability_clear_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_RELAX_EN);
+}
+EXPORT_SYMBOL(pcie_clear_relaxed_ordering);
+
+int pcie_get_relaxed_ordering(struct pci_dev *dev)
+{
+ u16 v;
+
+ pcie_capability_read_word(dev, PCI_EXP_DEVCTL, &v);
+
+ return (v & PCI_EXP_DEVCTL_RELAX_EN) >> 4;
+}
+EXPORT_SYMBOL(pcie_get_relaxed_ordering);
+
 /**
  * pcie_set_mps - set PCI Express maximum payload size
  * @dev: PCI device to query
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 19c8950..aeb22b5 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1701,6 +1701,16 @@ static void pci_configure_extended_tags(struct pci_dev *dev)
                                         PCI_EXP_DEVCTL_EXT_TAG);
 }

+static void pci_configure_relaxed_ordering(struct pci_dev *dev)
+{
+ int ret;
+
+ if (dev && (dev->dev_flags & PCI_DEV_FLAGS_NO_RELAXED_ORDERING))
+         pcie_set_relaxed_ordering(dev);
+ else
+         pcie_clear_relaxed_ordering(dev);
+}
+
 static void pci_configure_device(struct pci_dev *dev)
 {
        struct hotplug_params hpp;
@@ -1708,6 +1718,7 @@ static void pci_configure_device(struct pci_dev *dev)

        pci_configure_mps(dev);
        pci_configure_extended_tags(dev);
+ pci_configure_relaxed_ordering(dev);

        memset(&hpp, 0, sizeof(hpp));
        ret = pci_get_hp_params(dev, &hpp);


Thanks
Ding


>>> .
>>>
>>
> 
> .
> 
