From: Billy Shuman <wshuman3@gmail.com>
Subject: Re: 4.9.0-rc8: tg3 dead after resume
Date: Fri, 9 Dec 2016 09:29:12 -0500
Message-ID: <CAHQNsocRPWiVxpGBvzyXZ3tUnPCdM1d9JsyY2+phn28gqYrUTQ@mail.gmail.com>
References: <CAMet4B6t9neFPcGstZw6ebhFCBQzRsesStXZ8bjSaC5ggcuKxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michael Chan <michael.chan@broadcom.com>,
        Netdev <netdev@vger.kernel.org>
To: Siva Reddy Kallam <siva.kallam@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34966 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933687AbcLIO3y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 09:29:54 -0500
Received: by mail-io0-f180.google.com with SMTP id h30so58803917iod.2
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 06:29:53 -0800 (PST)
In-Reply-To: <CAMet4B6t9neFPcGstZw6ebhFCBQzRsesStXZ8bjSaC5ggcuKxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 8, 2016 at 4:03 AM, Siva Reddy Kallam
<siva.kallam@broadcom.com> wrote:
> On Thu, Dec 8, 2016 at 12:14 AM, Billy Shuman <wshuman3@gmail.com> wrote:
>> On Wed, Dec 7, 2016 at 12:37 PM, Michael Chan <michael.chan@broadcom.com> wrote:
>>> On Wed, Dec 7, 2016 at 7:20 AM, Billy Shuman <wshuman3@gmail.com> wrote:
>>>> After resume on 4.9.0-rc8 tg3 is dead.
>>>>
>>>> In logs I see:
>>>> kernel: tg3 0000:44:00.0: phy probe failed, err -19
>>>> kernel: tg3 0000:44:00.0: Problem fetching invariants of chip, aborting
>>>
>>> -19 is -ENODEV which means tg3 cannot read the PHY ID.
>>>
>>> If it's a true suspend/resume operation, the driver does not have to
>>> go through probe during resume.  Please explain how you do
>>> suspend/resume.
>>>
>>
>> Sorry my previous message was accidentally sent to early.
>>
>> I used systemd (systemctl suspend) to suspend.
>>
> We need more information to proceed further.
> Without suspend, Are you able to use the tg3 port?

Yes the port works fine without suspend.

> Which Broadcom card are you having in laptop?

The nic is a NetXtreme BCM57762 Gigabit Ethernet PCIe in a thunderbolt3 dock.

> Please provide complete tg3 specific logs in dmesg.
>

[   32.084010] tg3.c:v3.137 (May 11, 2014)
[   32.124695] tg3 0000:44:00.0 eth0: Tigon3 [partno(BCM957762) rev
57766001] (PCI Express) MAC address 98:e7:f4:8b:13:19
[   32.124698] tg3 0000:44:00.0 eth0: attached PHY is 57765
(10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[1])
[   32.124699] tg3 0000:44:00.0 eth0: RXcsums[1] LinkChgREG[0]
MIirq[0] ASF[0] TSOcap[1]
[   32.124700] tg3 0000:44:00.0 eth0: dma_rwctrl[00000001] dma_mask[64-bit]
[   32.219764] tg3 0000:44:00.0 enp68s0: renamed from eth0
[   36.219245] tg3 0000:44:00.0 enp68s0: Link is up at 1000 Mbps, full duplex
[   36.219250] tg3 0000:44:00.0 enp68s0: Flow control is on for TX and on for RX
[   36.219251] tg3 0000:44:00.0 enp68s0: EEE is disabled

after resume
[   92.292838] tg3 0000:44:00.0 enp68s0: No firmware running
[   93.521744] tg3 0000:44:00.0: tg3_abort_hw timed out,
TX_MODE_ENABLE will not clear MAC_TX_MODE=ffffffff
[  106.704655] tg3 0000:44:00.0 enp68s0: Link is down
[  108.370356] tg3 0000:44:00.0: tg3_abort_hw timed out,
TX_MODE_ENABLE will not clear MAC_TX_MODE=ffffffff

after rmmod, modprobe
[  570.933636] tg3 0000:44:00.0: tg3_abort_hw timed out,
TX_MODE_ENABLE will not clear MAC_TX_MODE=ffffffff
[  604.847215] tg3.c:v3.137 (May 11, 2014)
[  605.010075] tg3 0000:44:00.0: phy probe failed, err -19
[  605.010077] tg3 0000:44:00.0: Problem fetching invariants of chip, aborting




>>> Did this work before?  There has been very few changes to tg3 recently.
>>>
>>
>> This is a new laptop for me, but the same behavior is seen on 4.4.36 and 4.8.12.
>>
>>>>
>>>> rmmod and modprobe does not fix the problem only a reboot resolves the issue.
>>>>
>>>> Billy
