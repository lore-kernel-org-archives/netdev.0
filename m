From: Vijay Pandurangan <vijayp@vijayp.ca>
Subject: =?UTF-8?Q?Re=3A_veth_regression_with_=22don=E2=80=99t_modify_ip=5Fsummed=3B_?=
	=?UTF-8?Q?doing_so_treats_packets_with_bad_checksums_as_good=2E=22?=
Date: Fri, 25 Mar 2016 00:45:26 -0400
Message-ID: <CAKUBDd8vwvN4z5gP63ukVjRsgbjKQBZvVHv+bJdQRQgcxD5HGA@mail.gmail.com>
References: <56F463D6.7080406@candelatech.com> <CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com>
 <56F4810A.9060904@candelatech.com> <56F49036.8050902@candelatech.com>
 <56F490B2.3090603@candelatech.com> <CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com>
 <56F4BFF1.8010806@candelatech.com> <CAKUBDd8ojaAYHZ6L_8HBetqL1P6v9iy9W9ThZwnnzf3-npt-Vg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Cong Wang <cwang@twopensource.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:33103 "EHLO
	mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbcCYEpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 00:45:47 -0400
Received: by mail-vk0-f51.google.com with SMTP id k1so81648964vkb.0
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 21:45:47 -0700 (PDT)
In-Reply-To: <CAKUBDd8ojaAYHZ6L_8HBetqL1P6v9iy9W9ThZwnnzf3-npt-Vg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually, maybe they should be set to CHECKSUM_PARTIAL if we want veth
to drop the packets if they have bad checksums before they hit the
application level.

On Fri, Mar 25, 2016 at 12:41 AM, Vijay Pandurangan <vijayp@vijayp.ca> wrote:
> agreed. It should maybe be set to CHECKSUM_UNNECESSARY. The comment
> seems to imply that it's treated the same as CHECKSUM_NONE but that's
> evidently not true. I think that would fix the checksumming issue but
> I'm fearful it may break something else:
> http://lxr.free-electrons.com/source/include/linux/skbuff.h#L177
>
> I'm really worried there are other equally subtle bugs hidden in this
> code. Do we have any kind of regression test, or any automated way to
> test all possible values on an skb to determine side effects to any
> change here? (I'm new to the kernel so sorry if there's an answer in
> an FAQ somewhere).
>
> If not,
> 1. how should we ensure that our change doesn't break something else?
> 2. Should we audit / simplify the checksum code or come up with a list
> of test cases that covers all uses?
>
>
> On Fri, Mar 25, 2016 at 12:34 AM, Ben Greear <greearb@candelatech.com> wrote:
>>
>>
>> On 03/24/2016 06:44 PM, Vijay Pandurangan wrote:
>>>
>>> Oops, I think my last email didn't go through due to an inadvertent
>>> html attachment from my phone mail client.
>>>
>>> Can you send us a copy of a packet you're sending and/or confirm that
>>> the IP and UDP4 checksums are set correctly in the packet?
>>>
>>> If those are set right, I think we need to read through the networking
>>> code again to see why this is broken...
>>
>>
>> Wireshark decodes the packet as having no checksum errors.
>>
>> I think the contents of the packet is correct, but the 'ip_summed'
>> field is set incorrectly to 'NONE' when transmitting on a raw packet
>> socket.
>>
>>
>> Thanks,
>> Ben
>>
>> --
>> Ben Greear <greearb@candelatech.com>
>> Candela Technologies Inc  http://www.candelatech.com
