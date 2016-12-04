From: domingo montoya <reach.domingomontoya@gmail.com>
Subject: Re: mlx5 VST and VGT mode at the same time
Date: Sun, 4 Dec 2016 08:58:42 +0530
Message-ID: <CAOYAsNm9n6G4GCxVZqKqJ-XjXYkiGSoeFXvJHfBO1cUP7xanCA@mail.gmail.com>
References: <CAOYAsNm+t5rWGm+Xe_cq_2=D0H-Ue4uUNzR4LaVJXFueawd4xg@mail.gmail.com>
 <CANDJFw5uTvgBPa5howOnsff82MvM=DcpEnor1ZELtSg8xwrMew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Mohamad Haj Yahia <mohamadhajyahia.mellanox@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35430 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751939AbcLDD2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 22:28:44 -0500
Received: by mail-wm0-f46.google.com with SMTP id a197so51012420wmd.0
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 19:28:43 -0800 (PST)
In-Reply-To: <CANDJFw5uTvgBPa5howOnsff82MvM=DcpEnor1ZELtSg8xwrMew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks a lot Mohamad. This is really helpful.

On Mon, Aug 22, 2016 at 6:39 PM, Mohamad Haj Yahia
<mohamadhajyahia.mellanox@gmail.com> wrote:
> On Thu, Aug 18, 2016 at 12:41 PM, domingo montoya
> <reach.domingomontoya@gmail.com> wrote:
>> Hi All,
>>
>> Is there any way we can support both VST and VGT modes at the same time in mlx5?
>>
>> For e.g,
>>
>> If i send untagged packets from the VF, they should be tagged with the
>> VST vlan and the vlan be stripped for received packets.
>>
>> If i send tagged packets from the VF, they should be send as it and no
>> tag inserted for these and also the vlan tag not stripped for received
>> packets.
>>
>> Any way we can achieve this?
>>
>>
>> I understand that in the latest code these features are mutually exclusive.
>>
>> But if we have a requirement like this, any ideas on how to go about
>> implementing the same.
>>
>> Few observations:
>>
>> After going through the code, I figured out that for VST mode, we run
>> MODIFY_ESW_VPORT_CONTEXT and as part of this set the flag to strip the
>> vlan from the received packets. In case of VGT mode, because of this
>> command, the tags set by the VF driver also get stripped.
>>
>>
>>
>> Thanks a lot!
>>
>>
>> Best Regards,
>> Domingo
>
> Hi Domingo,
>
> Unfortunately there is a HW limitation that prevent VGT working
> besides VST on the same VF.
> Since the stripping feature is global attribute for all the VF
> incoming vlans, if we enable both modes you will see that the VGT
> traffic vlan also stripped and thus it will arrive to the VF as
> untagged.
> Because of this limitation we blocked the outgoing vlan tagged traffic
> from a VF that is in VST mode and also dropped incoming vlan tagged
> packets targeting that VF with a different vlan than the VF vlan-id.
> The VGT and VST mutual exclusive enforcement is done by VF ACL ingress
> and egress flow tables.
>
> Thanks,
> Mohamad
