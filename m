From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 1/2] PCI: Add new PCIe Fabric End Node flag, PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Mon, 8 May 2017 08:22:14 -0700
Message-ID: <CAKgT0Uej61MGJjxaZCXsVTVApO2bYTmChi0suXbLZ7vSf4Y9wQ@mail.gmail.com>
References: <cover.1493678834.git.leedom@chelsio.com> <758d0e431c732fe133e7b0e660bde5fc1beccdba.1493678834.git.leedom@chelsio.com>
 <CAKgT0UeuW88AHBX14H8xHteeG7vR0AH3apbjOeEDx_6p46x7tA@mail.gmail.com>
 <20170502165329.GB26406@linux.intel.com> <CAKgT0UcxjGCZu_QV-eF7_yWkDBbQpLpdaPqBf1gji8XXM5Cc=w@mail.gmail.com>
 <MWHPR12MB160095DF53CE981C923FE65DC8160@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0UdJ17DGAphuP5Y9co6ky-GBFdq2s-1nqctY_Tz_iz5__g@mail.gmail.com>
 <MWHPR12MB1600E78DD7F530AA9DC2433DC8EA0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0Ucwkp+fi-9HhMbze6t_i15dj4e2WQBp13Coi6MegrDh=w@mail.gmail.com>
 <22c46382-5778-022f-d0bd-74abec9e9c7c@huawei.com> <CAKgT0Ufg6uebqj79e1FOHoPpF-GxPYMkp353r3Ok_=nM8wF6qA@mail.gmail.com>
 <2a3f064b-e885-a528-4945-adb32904bd0e@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Casey Leedom <leedom@chelsio.com>,
        "Raj, Ashok" <ashok.raj@intel.com>,
        Bjorn Helgaas <helgaas@kernel.org>,
        Michael Werner <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "Arjun V." <arjun@chelsio.com>,
        Asit K Mallick <asit.k.mallick@intel.com>,
        Patrick J Cramer <patrick.j.cramer@intel.com>,
        Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
        Bob Shaw <Bob.Shaw@amd.com>, h <l.stach@pengutronix.de>,
        Mark Rutland <mark.rutland@arm.com>,
        Amir Ancel <amira@mellanox.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        LinuxArm <linuxarm@huawei.com>,
        David Laight <David.Laight@aculab.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Netdev <netdev@vger.kernel.o
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:38110 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752957AbdEHPWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 11:22:20 -0400
Received: by mail-it0-f54.google.com with SMTP id e65so40590406ita.1
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 08:22:20 -0700 (PDT)
In-Reply-To: <2a3f064b-e885-a528-4945-adb32904bd0e@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 8, 2017 at 7:33 AM, Ding Tianhong <dingtianhong@huawei.com> wrote:
>
>
> On 2017/5/7 2:07, Alexander Duyck wrote:
>> On Fri, May 5, 2017 at 8:08 PM, Ding Tianhong <dingtianhong@huawei.com> wrote:
>>>
>>>
>>> On 2017/5/5 22:04, Alexander Duyck wrote:
>>>> On Thu, May 4, 2017 at 2:01 PM, Casey Leedom <leedom@chelsio.com> wrote:
>>>>> | From: Alexander Duyck <alexander.duyck@gmail.com>
>>>>> | Sent: Wednesday, May 3, 2017 9:02 AM
>>>>> | ...
>>>>> | It sounds like we are more or less in agreement. My only concern is
>>>>> | really what we default this to. On x86 I would say we could probably
>>>>> | default this to disabled for existing platforms since my understanding
>>>>> | is that relaxed ordering doesn't provide much benefit on what is out
>>>>> | there right now when performing DMA through the root complex. As far
>>>>> | as peer-to-peer I would say we should probably look at enabling the
>>>>> | ability to have Relaxed Ordering enabled for some channels but not
>>>>> | others. In those cases the hardware needs to be smart enough to allow
>>>>> | for you to indicate you want it disabled by default for most of your
>>>>> | DMA channels, and then enabled for the select channels that are
>>>>> | handling the peer-to-peer traffic.
>>>>>
>>>>>   Yes, I think that we are mostly in agreement.  I had just wanted to make
>>>>> sure that whatever scheme was developed would allow for simultaneously
>>>>> supporting non-Relaxed Ordering for some PCIe End Points and Relaxed
>>>>> Ordering for others within the same system.  I.e. not simply
>>>>> enabling/disabling/etc.  based solely on System Platform Architecture.
>>>>>
>>>>>   By the way, I've started our QA folks off looking at what things look like
>>>>> in Linux Virtual Machines under different Hypervisors to see what
>>>>> information they may provide to the VM in the way of what Root Complex Port
>>>>> is being used, etc.  So far they've got Windows HyperV done and there
>>>>> there's no PCIe Fabric exposed in any way: just the attached device.  I'll
>>>>> have to see what pci_find_pcie_root_port() returns in that environment.
>>>>> Maybe NULL?
>>>>
>>>> I believe NULL is one of the options. It all depends on what qemu is
>>>> emulating. Most likely you won't find a pcie root port on KVM because
>>>> the default is to emulate an older system that only supports PCI.
>>>>
>>>>>   With your reservations (which I also share), I think that it probably
>>>>> makes sense to have a per-architecture definition of the "Can I Use Relaxed
>>>>> Ordering With TLPs Directed At This End Point" predicate, with the default
>>>>> being "No" for any architecture which doesn't implement the predicate.  And
>>>>> if the specified (struct pci_dev *) End Node is NULL, it ought to return
>>>>> False for that as well.  I can't see any reason to pass in the Source End
>>>>> Node but I may be missing something.
>>>>>
>>>>>   At this point, this is pretty far outside my level of expertise.  I'm
>>>>> happy to give it a go, but I'd be even happier if someone with a lot more
>>>>> experience in the PCIe Infrastructure were to want to carry the ball
>>>>> forward.  I'm not super familiar with the Linux Kernel "Rules Of
>>>>> Engagement", so let me know what my next step should be.  Thanks.
>>>>>
>>>>> Casey
>>>>
>>>> For now we can probably keep this on the linux-pci mailing list. Going
>>>> that route is the most straight forward for now since step one is
>>>> probably just making sure we are setting the relaxed ordering bit in
>>>> the setups that make sense. I would say we could probably keep it
>>>> simple. We just need to enable relaxed ordering by default for SPARC
>>>> architectures, on most others we can probably default it to off.
>>>>
>>>
>>> Casey, Alexander:
>>>
>>> Thanks for the wonderful discussion, it is more clearly that what to do next,
>>> I agree that enable relaxed ordering by default only for SPARC and ARM64
>>> is more safe for all the other platform, as no one want to break anything.
>>>
>>>> I believe this all had started as Ding Tianhong was hoping to enable
>>>> this for the ARM architecture. That is the only one I can think of
>>>> where it might be difficult to figure out which way to default as we
>>>> were attempting to follow the same code that was enabled for SPARC and
>>>> that is what started this tug-of-war about how this should be done.
>>>> What we might do is take care of this in two phases. The first one
>>>> enables the infrastructure generically but leaves it defaulted to off
>>>> for everyone but SPARC. Then we can go through and start enabling it
>>>> for other platforms such as some of those on ARM in the platforms that
>>>> Ding Tianhong was working with.
>>>>
>>>
>>> According the suggestion, I could only think of this code:
>>>
>>> @@ -3979,6 +3979,15 @@ static void quirk_tw686x_class(struct pci_dev *pdev)
>>>  DECLARE_PCI_FIXUP_CLASS_EARLY(0x1797, 0x6869, PCI_CLASS_NOT_DEFINED, 8,
>>>                               quirk_tw686x_class);
>>>
>>> +static void quirk_relaxedordering_disable(struct pci_dev *dev)
>>> +{
>>> + if (dev->vendor != PCI_VENDOR_ID_HUAWEI &&
>>> +     dev->vendor != PCI_VENDOR_ID_SUN)
>>> +         dev->dev_flags |= PCI_DEV_FLAGS_NO_RELAXED_ORDERING;
>>> +}
>>> +DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_INTEL_ID, PCI_ANY_ID, PCI_CLASS_NOT_DEFINED, 8,
>>> +                       quirk_relaxedordering_disable);
>>> +
>>>  /*
>>>   * Per PCIe r3.0, sec 2.2.9, "Completion headers must supply the same
>>>   * values for the Attribute as were supplied in the header of the
>>>
>>>
>>> What do you think of it?
>>>
>>> Thanks
>>> Ding
>>>
>>
>> This is a bit simplistic but it is a start.
>>
>> The other bit I was getting at is that we need to update the core PCIe
>> code so that when we configure devices and the root complex reports no
>> support for relaxed ordering it should be clearing the relaxed
>> ordering bits in the PCIe configuration registers on the upstream
>> facing devices.
>
> How about this:
> rename the PCI_DEV_FLAGS_NO_RELAXED_ORDERIN to PCI_DEV_FLAGS_RELAXED_ORDERIN, only enable it
> when pcie root configure if it support the RO mode, otherwise we will not set it to indicate
> that the pcie dev did not support RO mode.

The problem is we need to have something that can be communicated
through a VM. Your change doesn't work in that regard. That was why I
suggested just updating the code so that we when we initialized PCIe
devices what we do is either set or clear the relaxed ordering bit in
the PCIe device control register. That way when we direct assign an
interface it could know just based on the bits int the PCIe
configuration if it could use relaxed ordering or not.

At that point the driver code itself becomes very simple since you
could just enable the relaxed ordering by default in the igb/ixgbe
driver and if the bit is set or cleared in the PCIe configuration then
we are either sending with relaxed ordering requests or not and don't
have to try and locate the root complex.

>>
>> The last bit we need in all this is a way to allow for setups where
>> peer-to-peer wants to perform relaxed ordering but for writes to the
>> host we have to not use relaxed ordering. For that we need to enable a
>> special case and that isn't handled right now in any of the solutions
>> we have coded up so far.
>>
>
> Sorry I am not clear of this way, can you explain more about this or give me
> a special case, thanks a lot.

So from the sound of it Casey has a special use case where he doesn't
want to send relaxed ordering frames to the root complex, but instead
would like to send them to another PCIe device. To do that he needs to
have a way to enable the relaxed ordering bit in the PCIe
configuration but then not send any to the root complex. Odds are that
is something he might be able to just implement in the driver, but is
something that may become a more general case in the future. I don't
see our change here impacting it as long as we keep the solution
generic and mostly confined to when we instantiate the devices as the
driver could likely make the decision to change the behavior later.

- Alex
