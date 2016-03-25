From: Vijay Pandurangan <vijayp@vijayp.ca>
Subject: =?UTF-8?Q?Re=3A_veth_regression_with_=22don=E2=80=99t_modify_ip=5Fsummed=3B_?=
	=?UTF-8?Q?doing_so_treats_packets_with_bad_checksums_as_good=2E=22?=
Date: Fri, 25 Mar 2016 17:51:16 -0400
Message-ID: <CAKUBDd-hw95+9EHiXj_4qhjK1iSvFpX4S2VOb+Cw5Z9of1b98g@mail.gmail.com>
References: <56F463D6.7080406@candelatech.com> <CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com>
 <56F4810A.9060904@candelatech.com> <56F49036.8050902@candelatech.com>
 <56F490B2.3090603@candelatech.com> <CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com>
 <56F4BFF1.8010806@candelatech.com> <CAKUBDd8ojaAYHZ6L_8HBetqL1P6v9iy9W9ThZwnnzf3-npt-Vg@mail.gmail.com>
 <CAKUBDd8vwvN4z5gP63ukVjRsgbjKQBZvVHv+bJdQRQgcxD5HGA@mail.gmail.com>
 <56F4C77E.1010608@candelatech.com> <CAKUBDd9qs9rzrvp8XJ4HpddekMsRjmL+rwsL3DqTWutPon=NdA@mail.gmail.com>
 <56F54CB7.9010300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Cong Wang <cwang@twopensource.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:33637 "EHLO
	mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273AbcCYVvh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 17:51:37 -0400
Received: by mail-vk0-f43.google.com with SMTP id k1so102848615vkb.0
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 14:51:36 -0700 (PDT)
In-Reply-To: <56F54CB7.9010300@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 10:35 AM, Ben Greear <greearb@candelatech.com> =
wrote:
>
>
> On 03/24/2016 10:24 PM, Vijay Pandurangan wrote:
>>
>> On Fri, Mar 25, 2016 at 1:07 AM, Ben Greear <greearb@candelatech.com=
>
>> wrote:
>>>
>>> On 03/24/2016 09:45 PM, Vijay Pandurangan wrote:
>>>>
>>>>
>>>> Actually, maybe they should be set to CHECKSUM_PARTIAL if we want =
veth
>>>> to drop the packets if they have bad checksums before they hit the
>>>> application level.
>>>
>>>
>>>
>>> VETH is pretty special in that when you transmit a frame on one
>>> device, it's pair receives it, and unless there is RAM corruption
>>> or bugs in the kernel, then it cannot be corrupted.
>>
>>
>> Yeah, you're right that that's an optimization. However, I think tha=
t
>> we should first ensure that
>>
>> a->veth->b
>>
>> operates exactly like:
>>
>> a->physical eth 1 -> physical eth 2->b
>>
>> in all cases.  Once we have that working everywhere we could think
>> about optimizations.
>>
>>
>> If we're willing to refactor, we could implement the optimization by
>> allowing veth devices to know whether their immediate peer is. If a
>> veth knows it's talking to another veth, it could under some
>> circumstances elide checksum calculation and verification.  I'm not
>> sure what abstractions that would break, though. What do you guys
>> think?
>
>
> veth ALWAYS transmits to another VETH.  The problem is that when veth=
 is
> given a packet to transmit, it is difficult to know where that packet
> came from.

Yeah you're totally right =E2=80=93 I guess what I was trying to expres=
s (but
failed at) was that we might need to be able to track the original
source of the packet for optimizations.
>
> And, adding software checksumming to veth for every frame would be a =
huge
> performance hit.
>
>
> Thanks,
> Ben
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
