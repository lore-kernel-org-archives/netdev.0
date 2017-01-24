From: Siva Reddy Kallam <siva.kallam@broadcom.com>
Subject: Re: 4.9.0-rc8: tg3 dead after resume
Date: Tue, 24 Jan 2017 15:25:47 +0530
Message-ID: <CAMet4B7d8YkGZCU3EB3MfVht9UPhM=v=m_OWuUh898oAbsjX8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Michael Chan <michael.chan@broadcom.com>,
        Netdev <netdev@vger.kernel.org>
To: Billy Shuman <wshuman3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:33258 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750707AbdAXJz7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 04:55:59 -0500
Received: by mail-qt0-f177.google.com with SMTP id v23so173003939qtb.0
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 01:55:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2017 at 8:29 PM, Billy Shuman <wshuman3@gmail.com> wrote:
> On Mon, Jan 16, 2017 at 2:15 AM, Siva Reddy Kallam
> <siva.kallam@broadcom.com> wrote:
>> Hi,
>>
>> Sorry for the late reply.
>> We don't have exact model.
>> We tried to reproduce with HP elitebook folio laptop & HP elite thunderb=
olt
>> 3 dock.
>> We observed issue with Thunder bolt bridge. All the connected devices on=
 the
>> TH3 dock don't function at all.
>> Are you observing same issue? Did you get a chance to check with HP on t=
his?
>
> No the only device that does not function is the nic and only after resum=
e, it
> functions prior to that.  I have a usb keyboard and three monitors
> attached to the
> dock that function properly before and after resume.  Did you turn off
> authentication for thunderbolt in bios?
Do you mean Thunderbolt Security Level to =E2=80=9CPCIe and DisplayPort - N=
o Security=E2=80=9D?
If Yes, We already set the same and using it.
As we are unable to reproduce, Can you please check with HP once on this?
>
>> As per our discussion with HP, Thunder bolt bridge driver is provided fo=
r
>> windows OS only.
>>
>> Regards,
>> Siva
>> ----Original Message-----
>> From: Billy Shuman [mailto:wshuman3@gmail.com]
>> Sent: Wednesday, December 28, 2016 7:33 PM
>> To: Siva Reddy Kallam <siva.kallam@broadcom.com>
>> Subject: Re: 4.9.0-rc8: tg3 dead after resume
>>
>> On Mon, Dec 26, 2016 at 1:27 AM, Siva Reddy Kallam
>> <siva.kallam@broadcom.com> wrote:
>>> On Mon, Dec 12, 2016 at 3:53 PM, Siva Reddy Kallam
>>> <siva.kallam@broadcom.com> wrote:
>>>> On Fri, Dec 9, 2016 at 7:59 PM, Billy Shuman <wshuman3@gmail.com> wrot=
e:
>>>>> On Thu, Dec 8, 2016 at 4:03 AM, Siva Reddy Kallam
>>>>> <siva.kallam@broadcom.com> wrote:
>>>>>> On Thu, Dec 8, 2016 at 12:14 AM, Billy Shuman <wshuman3@gmail.com>
>>>>>> wrote:
>>>>>>> On Wed, Dec 7, 2016 at 12:37 PM, Michael Chan
>>>>>>> <michael.chan@broadcom.com> wrote:
>>>>>>>> On Wed, Dec 7, 2016 at 7:20 AM, Billy Shuman <wshuman3@gmail.com>
>>>>>>>> wrote:
>>>>>>>>> After resume on 4.9.0-rc8 tg3 is dead.
>>>>>>>>>
>>>>>>>>> In logs I see:
>>>>>>>>> kernel: tg3 0000:44:00.0: phy probe failed, err -19
>>>>>>>>> kernel: tg3 0000:44:00.0: Problem fetching invariants of chip,
>>>>>>>>> aborting
>>>>>>>>
>>>>>>>> -19 is -ENODEV which means tg3 cannot read the PHY ID.
>>>>>>>>
>>>>>>>> If it's a true suspend/resume operation, the driver does not have
>>>>>>>> to go through probe during resume.  Please explain how you do
>>>>>>>> suspend/resume.
>>>>>>>>
>>>>>>>
>>>>>>> Sorry my previous message was accidentally sent to early.
>>>>>>>
>>>>>>> I used systemd (systemctl suspend) to suspend.
>>>>>>>
>>>>>> We need more information to proceed further.
>>>>>> Without suspend, Are you able to use the tg3 port?
>>>>>
>>>>> Yes the port works fine without suspend.
>>>> OK
>>>>>
>>>>>> Which Broadcom card are you having in laptop?
>>>>>
>>>>> The nic is a NetXtreme BCM57762 Gigabit Ethernet PCIe in a thunderbol=
t3
>>>>> dock.
>>>>>
>>>> OK
>>>>>> Please provide complete tg3 specific logs in dmesg.
>>>>>>
>>>>>
>>>>> [   32.084010] tg3.c:v3.137 (May 11, 2014)
>>>>> [   32.124695] tg3 0000:44:00.0 eth0: Tigon3 [partno(BCM957762) rev
>>>>> 57766001] (PCI Express) MAC address 98:e7:f4:8b:13:19
>>>>> [   32.124698] tg3 0000:44:00.0 eth0: attached PHY is 57765
>>>>> (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[1])
>>>>> [   32.124699] tg3 0000:44:00.0 eth0: RXcsums[1] LinkChgREG[0]
>>>>> MIirq[0] ASF[0] TSOcap[1]
>>>>> [   32.124700] tg3 0000:44:00.0 eth0: dma_rwctrl[00000001]
>>>>> dma_mask[64-bit]
>>>>> [   32.219764] tg3 0000:44:00.0 enp68s0: renamed from eth0
>>>>> [   36.219245] tg3 0000:44:00.0 enp68s0: Link is up at 1000 Mbps, ful=
l
>>>>> duplex
>>>>> [   36.219250] tg3 0000:44:00.0 enp68s0: Flow control is on for TX an=
d
>>>>> on for RX
>>>>> [   36.219251] tg3 0000:44:00.0 enp68s0: EEE is disabled
>>>>>
>>>>> after resume
>>>>> [   92.292838] tg3 0000:44:00.0 enp68s0: No firmware running
>>>>> [   93.521744] tg3 0000:44:00.0: tg3_abort_hw timed out,
>>>>> TX_MODE_ENABLE will not clear MAC_TX_MODE=3Dffffffff [  106.704655]
>>>>> tg3 0000:44:00.0 enp68s0: Link is down [  108.370356] tg3
>>>>> 0000:44:00.0: tg3_abort_hw timed out, TX_MODE_ENABLE will not clear
>>>>> MAC_TX_MODE=3Dffffffff
>>>>>
>>>>> after rmmod, modprobe
>>>>> [  570.933636] tg3 0000:44:00.0: tg3_abort_hw timed out,
>>>>> TX_MODE_ENABLE will not clear MAC_TX_MODE=3Dffffffff [  604.847215]
>>>>> tg3.c:v3.137 (May 11, 2014) [  605.010075] tg3 0000:44:00.0: phy
>>>>> probe failed, err -19 [  605.010077] tg3 0000:44:00.0: Problem
>>>>> fetching invariants of chip, aborting
>>>>>
>>>>>
>>>>>
>>>>>
>>>> We will try to reproduce and update you on this.
>>> We are unable to reproduce this issue with Ubuntu 16.10 (K4.8.0-22)
>>> kernel.
>>> We are in the process of verifying with 4.9.0-rc8  kernel and let you
>>> know the feedback.
>>> Can you please let us know the make/model of your laptop and procedure
>>> followed to enable tg3 driver?
>>
>> The model is an HP Zbook Studio G3.
>> The NIC is in the dock which is an HP Zbook Thunderbolt 3 dock.
>>
>> The module is loaded via udev.
>> $ cat config | grep CONFIG_TIGON3
>> CONFIG_TIGON3=3Dm
>>
>>>>>>>> Did this work before?  There has been very few changes to tg3
>>>>>>>> recently.
>>>>>>>>
>>>>>>>
>>>>>>> This is a new laptop for me, but the same behavior is seen on 4.4.3=
6
>>>>>>> and 4.8.12.
>>>>>>>
>>>>>>>>>
>>>>>>>>> rmmod and modprobe does not fix the problem only a reboot resolve=
s
>>>>>>>>> the issue.
>>>>>>>>>
>>>>>>>>> Billy
