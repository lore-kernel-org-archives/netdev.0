From: jacob jacob <opstkusr@gmail.com>
Subject: Re: [Qemu-devel] PCI passthrough of 40G ethernet interface (Openstack/KVM)
Date: Fri, 20 Mar 2015 16:55:49 -0400
Message-ID: <CA+AkT2jPV_P436_RUQepT7wHtPaGOYGeE5uzUKtyXtk0s8U_gQ@mail.gmail.com>
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
	<CA+AkT2g-Xt+hcpoh2ETx70v0mzV6m=-5zpxJrhs2C8WF--kmWw@mail.gmail.com>
	<CAP-MU4PSMMOv-sjfDtKOSaHa9-dy3cMovsHV7V_cV1k6N7yvFg@mail.gmail.com>
	<CAP-MU4Pfv9W9FgaLxwOac3LnSJMxWcbYP4Pq43YjcJ9AWAamvQ@mail.gmail.com>
	<550A85B3.4070703@redhat.com>
	<CA+AkT2hJcHBcTzyONosrd82dD1m3-ML1_doS=tjBFoAPdnTmaw@mail.gmail.com>
	<550ADAD2.8070506@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shannon Nelson <shannon.nelson@intel.com>,
	Bandan Das <bsd@redhat.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	QEMU Developers <qemu-devel@nongnu.org>,
	kvm-devel <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <550ADAD2.8070506@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 19, 2015 at 10:18 AM, Stefan Assmann <sassmann@redhat.com> wrote:
> On 19.03.2015 15:04, jacob jacob wrote:
>> Hi Stefan,
>> have you been able to get PCI passthrough working without any issues
>> after the upgrade?
>
> My XL710 fails to transfer regular TCP traffic (netperf). If that works
> for you then you're already one step ahead of me. Afraid I can't help
> you there.

I have data transfer working when trying the test runs on the host
itself. Are you seeing problems when directly trying the TCP traffic
from the host itself?
The issues that i am seeing are specific to the case when the devices
are passed via PCI passthrough into the VM.

Any ideas whether this would be a kvm/qemu or i40e driver issue?
(Updating to the latest firmware and using latest i40e driver didn't
seem to help.)


>
>   Stefan
>
>> Thanks
>> Jacob
>>
>> On Thu, Mar 19, 2015 at 4:15 AM, Stefan Assmann <sassmann@redhat.com> wrote:
>>> On 18.03.2015 23:06, Shannon Nelson wrote:
>>>> On Wed, Mar 18, 2015 at 3:01 PM, Shannon Nelson
>>>> <shannon.nelson@intel.com> wrote:
>>>>>
>>>>>
>>>>> On Wed, Mar 18, 2015 at 8:40 AM, jacob jacob <opstkusr@gmail.com> wrote:
>>>>>>
>>>>>> On Wed, Mar 18, 2015 at 11:24 AM, Bandan Das <bsd@redhat.com> wrote:
>>>>>>>
>>>>>>> Actually, Stefan suggests that support for this card is still sketchy
>>>>>>> and your best bet is to try out net-next
>>>>>>> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git
>>>>>>>
>>>>>>> Also, could you please post more information about your hardware setup
>>>>>>> (chipset/processor/firmware version on the card etc) ?
>>>>>>
>>>>>> Host CPU : Model name:            Intel(R) Xeon(R) CPU E5-2630 v2 @ 2.60GHz
>>>>>>
>>>>>> Manufacturer Part Number:  XL710QDA1BLK
>>>>>> Ethernet controller: Intel Corporation Ethernet Controller XL710 for
>>>>>> 40GbE QSFP+ (rev 01)
>>>>>>  #ethtool -i enp9s0
>>>>>> driver: i40e
>>>>>> version: 1.2.6-k
>>>>>> firmware-version: f4.22 a1.1 n04.24 e800013fd
>>>>>> bus-info: 0000:09:00.0
>>>>>> supports-statistics: yes
>>>>>> supports-test: yes
>>>>>> supports-eeprom-access: yes
>>>>>> supports-register-dump: yes
>>>>>> supports-priv-flags: no
>>>>>>
>>>>
>>>> Jacob,
>>>>
>>>> It looks like you're using a NIC with the e800013fd firmware from last
>>>> summer, and from a separate message that you saw these issues with
>>>> both the 1.2.2-k and the 1.2.37 version drivers.  I suggest the next
>>>> step would be to update the NIC firmware as there are some performance
>>>> and stability updates available that deal with similar issues.  Please
>>>> see the Intel Networking support webpage at
>>>> https://downloadcenter.intel.com/download/24769 and look for the
>>>> NVMUpdatePackage.zip.  This should take care of several of the things
>>>> Stefan might describe as "sketchy" :-).
>>>
>>> Interesting, the following might explain why my XL710 feels a bit
>>> sketchy then. ;-)
>>> # ethtool -i p4p1
>>> driver: i40e
>>> version: 1.2.37-k
>>> firmware-version: f4.22.26225 a1.1 n4.24 e12ef
>>> Looks like the firmware on this NIC is even older.
>>>
>>> I tried to update the firmware with nvmupdate64e and the first thing I
>>> noticed is that you cannot update the firmware even with todays linux
>>> git. The tool errors out because it cannot access the NVM. Only with a
>>> recent net-next kernel I was able to update the firmware.
>>> ethtool -i p4p1
>>> driver: i40e
>>> version: 1.2.37-k
>>> firmware-version: f4.33.31377 a1.2 n4.42 e1932
>>>
>>> However during the update I got a lot of errors in dmesg.
>>> [  301.796664] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0702 received
>>> [  301.893933] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received
>>> [  302.005223] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received
>>> [...]
>>> [  387.884635] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received
>>> [  387.896862] i40e 0000:82:00.0: ARQ Overflow Error detected
>>> [  387.902995] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received
>>> [...]
>>> [  391.583799] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
>>> [  391.714217] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
>>> [  391.842656] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
>>> [  391.973080] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
>>> [  392.107586] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
>>> [  392.244140] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
>>> [  392.373966] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received
>>>
>>> Not sure if that flash was actually successful or not.
>>>
>>>   Stefan
>
