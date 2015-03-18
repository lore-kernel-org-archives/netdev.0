From: jacob jacob <opstkusr@gmail.com>
Subject: Re: [Qemu-devel] PCI passthrough of 40G ethernet interface (Openstack/KVM)
Date: Wed, 18 Mar 2015 11:40:41 -0400
Message-ID: <CA+AkT2g-Xt+hcpoh2ETx70v0mzV6m=-5zpxJrhs2C8WF--kmWw@mail.gmail.com>
References: <CA+AkT2g=vFxKAUrHzWDxPzfq_SNvOUJvzHe5YsX+p+p6Ad8hog@mail.gmail.com>
	<jpg8uf2ghln.fsf@redhat.com>
	<CA+AkT2hZ5e=YRkSqQnpQm9CgfC_fqs-m_05FTRZQLt9ynj9A4w@mail.gmail.com>
	<jpgtwxpvk5x.fsf@redhat.com>
	<CA+AkT2j9UUTVmEsW1B4D_cvfCTjp-+62qhvnYxcrthy=QmQcaw@mail.gmail.com>
	<CA+AkT2gXouCdMWzRJBY0jYi6O61OjDnNf7XGnfLzhYkJCe00mg@mail.gmail.com>
	<jpg1tko7qwb.fsf@redhat.com>
	<CA+AkT2i2z+DGV0aezUQaOLKrVupprniuxC19xGOuNnd6gC1ZGg@mail.gmail.com>
	<jpglhiw4tal.fsf@redhat.com>
	<jpgk2yewcpt.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alex Williamson <alex.williamson@redhat.com>,
	QEMU Developers <qemu-devel@nongnu.org>,
	kvm-devel <kvm@vger.kernel.org>,
	Stefan Assmann <sassmann@redhat.com>, netdev@vger.kernel.org
To: Bandan Das <bsd@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:35159 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbbCRPkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 11:40:43 -0400
In-Reply-To: <jpgk2yewcpt.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 18, 2015 at 11:24 AM, Bandan Das <bsd@redhat.com> wrote:
> [Ccing netdev and Stefan]
> Bandan Das <bsd@redhat.com> writes:
>
>> jacob jacob <opstkusr@gmail.com> writes:
>>
>>> On Mon, Mar 16, 2015 at 2:12 PM, Bandan Das <bsd@redhat.com> wrote:
>>>> jacob jacob <opstkusr@gmail.com> writes:
>>>>
>>>>> I also see the following in dmesg in the VM.
>>>>>
>>>>> [    0.095758] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
>>>>> [    0.096006] acpi PNP0A03:00: ACPI _OSC support notification failed,
>>>>> disabling PCIe ASPM
>>>>> [    0.096915] acpi PNP0A03:00: Unable to request _OSC control (_OSC
>>>>> support mask: 0x08)
>>>> IIRC, For OSC control, after BIOS is done with (whatever initialization
>>>> it needs to do), it clears a bit so that the OS can take over. This message,
>>>> you are getting is a sign of a bug in the BIOS (usually). But I don't
>>>> know if this is related to your problem. Does "dmesg | grep -e DMAR -e IOMMU"
>>>> give anything useful ?
>>>
>>> Do not see anything useful in the output..
>>
>> Ok, Thanks. Can you please post the output as well ?
>>
>>>>> [    0.097072] acpi PNP0A03:00: fail to add MMCONFIG information,
>>>>> can't access extended PCI configuration space under this bridge.
>>>>>
>>>>> Does this indicate any issue related to PCI passthrough?
>>>>>
>>>>> Would really appreciate any input on how to bebug this further.
>>>>
>>>> Did you get a chance to try a newer kernel ?
>>> Currently am using 3.18.7-200.fc21.x86_64 which is pretty recent.
>>> Are you suggesting trying the newer kernel just on the host? (or VM too?)
>> Both preferably to 3.19. But it's just a wild guess. I saw i40e related fixes,
>> particularly "i40e: fix un-necessary Tx hangs" in 3.19-rc5. This is not exactly
>> what you are seeing but I was still wondering if it could help.
>
> Actually, Stefan suggests that support for this card is still sketchy
> and your best bet is to try out net-next
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git
>
> Also, could you please post more information about your hardware setup
> (chipset/processor/firmware version on the card etc) ?

Host CPU : Model name:            Intel(R) Xeon(R) CPU E5-2630 v2 @ 2.60GHz

Manufacturer Part Number:  XL710QDA1BLK
Ethernet controller: Intel Corporation Ethernet Controller XL710 for
40GbE QSFP+ (rev 01)
 #ethtool -i enp9s0
driver: i40e
version: 1.2.6-k
firmware-version: f4.22 a1.1 n04.24 e800013fd
bus-info: 0000:09:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no


> Thanks,
> Bandan
>
>> Meanwhile, I am trying to get hold of a card myself to try and reproduce
>> it at my end.
>>
>> Thanks,
>> Bandan
>>
>>>>> On Fri, Mar 13, 2015 at 10:08 AM, jacob jacob <opstkusr@gmail.com> wrote:
>>>>>>> So, it could be the i40e driver then ? Because IIUC, VFs use a separate
>>>>>>> driver. Just to rule out the possibility that there might be some driver fixes that
>>>>>>> could help with this, it might be a good idea to try a 3.19 or later upstream
>>>>>>> kernel.
>>>>>>>
>>>>>>
>>>>>> I tried with the latest DPDK release too (dpdk-1.8.0) and see the same issue.
>>>>>> As mentioned earlier, i do not see any issues at all when running
>>>>>> tests using either i40e or dpdk on the host itself.
>>>>>> This is the reason why i am suspecting if it is anything to do with KVM/libvirt.
>>>>>> Both with regular PCI passthrough and VF passthrough i see issues. It
>>>>>> is always pointing to some issue with packet transmission. Receive
>>>>>> seems to work ok.
>>>>>>
>>>>>>
>>>>>> On Thu, Mar 12, 2015 at 8:02 PM, Bandan Das <bsd@redhat.com> wrote:
>>>>>>> jacob jacob <opstkusr@gmail.com> writes:
>>>>>>>
>>>>>>>> On Thu, Mar 12, 2015 at 3:07 PM, Bandan Das <bsd@redhat.com> wrote:
>>>>>>>>> jacob jacob <opstkusr@gmail.com> writes:
>>>>>>>>>
>>>>>>>>>>  Hi,
>>>>>>>>>>
>>>>>>>>>>  Seeing failures when trying to do PCI passthrough of Intel XL710 40G
>>>>>>>>>> interface to KVM vm.
>>>>>>>>>>      0a:00.1 Ethernet controller: Intel Corporation Ethernet
>>>>>>>>>> Controller XL710 for 40GbE QSFP+ (rev 01)
>>>>>>>>>
>>>>>>>>> You are assigning the PF right ? Does assigning VFs work or it's
>>>>>>>>> the same behavior ?
>>>>>>>>
>>>>>>>> Yes.Assigning VFs worked ok.But this had other issues while bringing down VMs.
>>>>>>>> Interested in finding out if PCI passthrough of 40G intel XL710
>>>>>>>> interface is qualified in some specific kernel/kvm release.
>>>>>>>
>>>>>>> So, it could be the i40e driver then ? Because IIUC, VFs use a separate
>>>>>>> driver. Just to rule out the possibility that there might be some driver fixes that
>>>>>>> could help with this, it might be a good idea to try a 3.19 or later upstream
>>>>>>> kernel.
>>>>>>>
>>>>>>>>>> From dmesg on host:
>>>>>>>>>>
>>>>>>>>>>> [80326.559674] kvm: zapping shadow pages for mmio generation wraparound
>>>>>>>>>>> [80327.271191] kvm [175994]: vcpu0 unhandled rdmsr: 0x1c9
>>>>>>>>>>> [80327.271689] kvm [175994]: vcpu0 unhandled rdmsr: 0x1a6
>>>>>>>>>>> [80327.272201] kvm [175994]: vcpu0 unhandled rdmsr: 0x1a7
>>>>>>>>>>> [80327.272681] kvm [175994]: vcpu0 unhandled rdmsr: 0x3f6
>>>>>>>>>>> [80327.376186] kvm [175994]: vcpu0 unhandled rdmsr: 0x606
>>>>>>>>>
>>>>>>>>> These are harmless and are related to unimplemented PMU msrs,
>>>>>>>>> not VFIO.
>>>>>>>>>
>>>>>>>>> Bandan
>>>>>>>> --
>>>>>>>> To unsubscribe from this list: send the line "unsubscribe kvm" in
>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
