From: Mohamad Haj Yahia <mohamadhajyahia.mellanox@gmail.com>
Subject: Re: mlx5 VST and VGT mode at the same time
Date: Mon, 22 Aug 2016 16:09:04 +0300
Message-ID: <CANDJFw5uTvgBPa5howOnsff82MvM=DcpEnor1ZELtSg8xwrMew@mail.gmail.com>
References: <CAOYAsNm+t5rWGm+Xe_cq_2=D0H-Ue4uUNzR4LaVJXFueawd4xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: domingo montoya <reach.domingomontoya@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36756 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752538AbcHVNJF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 09:09:05 -0400
Received: by mail-oi0-f52.google.com with SMTP id f189so149276158oig.3
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 06:09:05 -0700 (PDT)
In-Reply-To: <CAOYAsNm+t5rWGm+Xe_cq_2=D0H-Ue4uUNzR4LaVJXFueawd4xg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 18, 2016 at 12:41 PM, domingo montoya
<reach.domingomontoya@gmail.com> wrote:
> Hi All,
>
> Is there any way we can support both VST and VGT modes at the same time in mlx5?
>
> For e.g,
>
> If i send untagged packets from the VF, they should be tagged with the
> VST vlan and the vlan be stripped for received packets.
>
> If i send tagged packets from the VF, they should be send as it and no
> tag inserted for these and also the vlan tag not stripped for received
> packets.
>
> Any way we can achieve this?
>
>
> I understand that in the latest code these features are mutually exclusive.
>
> But if we have a requirement like this, any ideas on how to go about
> implementing the same.
>
> Few observations:
>
> After going through the code, I figured out that for VST mode, we run
> MODIFY_ESW_VPORT_CONTEXT and as part of this set the flag to strip the
> vlan from the received packets. In case of VGT mode, because of this
> command, the tags set by the VF driver also get stripped.
>
>
>
> Thanks a lot!
>
>
> Best Regards,
> Domingo

Hi Domingo,

Unfortunately there is a HW limitation that prevent VGT working
besides VST on the same VF.
Since the stripping feature is global attribute for all the VF
incoming vlans, if we enable both modes you will see that the VGT
traffic vlan also stripped and thus it will arrive to the VF as
untagged.
Because of this limitation we blocked the outgoing vlan tagged traffic
from a VF that is in VST mode and also dropped incoming vlan tagged
packets targeting that VF with a different vlan than the VF vlan-id.
The VGT and VST mutual exclusive enforcement is done by VF ACL ingress
and egress flow tables.

Thanks,
Mohamad
