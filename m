From: Ben Greear <greearb@candelatech.com>
Subject: Re: veth regression with =?UTF-8?B?ImRvbuKAmXQgbW9kaWZ5IGlwX3N1bQ==?=
 =?UTF-8?B?bWVkOyBkb2luZyBzbyB0cmVhdHMgcGFja2V0cyB3aXRoIGJhZCBjaGVja3N1bXM=?=
 =?UTF-8?B?IGFzIGdvb2QuIg==?=
Date: Fri, 25 Mar 2016 07:35:35 -0700
Message-ID: <56F54CB7.9010300@candelatech.com>
References: <56F463D6.7080406@candelatech.com> <CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com> <56F4810A.9060904@candelatech.com> <56F49036.8050902@candelatech.com> <56F490B2.3090603@candelatech.com> <CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com> <56F4BFF1.8010806@candelatech.com> <CAKUBDd8ojaAYHZ6L_8HBetqL1P6v9iy9W9ThZwnnzf3-npt-Vg@mail.gmail.com> <CAKUBDd8vwvN4z5gP63ukVjRsgbjKQBZvVHv+bJdQRQgcxD5HGA@mail.gmail.com> <56F4C77E.1010608@candelatech.com> <CAKUBDd9qs9rzrvp8XJ4HpddekMsRjmL+rwsL3DqTWutPon=NdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Cong Wang <cwang@twopensource.com>
To: Vijay Pandurangan <vijayp@vijayp.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:35998 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbcCYOfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 10:35:37 -0400
In-Reply-To: <CAKUBDd9qs9rzrvp8XJ4HpddekMsRjmL+rwsL3DqTWutPon=NdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/24/2016 10:24 PM, Vijay Pandurangan wrote:
> On Fri, Mar 25, 2016 at 1:07 AM, Ben Greear <greearb@candelatech.com> wrote:
>> On 03/24/2016 09:45 PM, Vijay Pandurangan wrote:
>>>
>>> Actually, maybe they should be set to CHECKSUM_PARTIAL if we want veth
>>> to drop the packets if they have bad checksums before they hit the
>>> application level.
>>
>>
>> VETH is pretty special in that when you transmit a frame on one
>> device, it's pair receives it, and unless there is RAM corruption
>> or bugs in the kernel, then it cannot be corrupted.
>
> Yeah, you're right that that's an optimization. However, I think that
> we should first ensure that
>
> a->veth->b
>
> operates exactly like:
>
> a->physical eth 1 -> physical eth 2->b
>
> in all cases.  Once we have that working everywhere we could think
> about optimizations.
>
>
> If we're willing to refactor, we could implement the optimization by
> allowing veth devices to know whether their immediate peer is. If a
> veth knows it's talking to another veth, it could under some
> circumstances elide checksum calculation and verification.  I'm not
> sure what abstractions that would break, though. What do you guys
> think?

veth ALWAYS transmits to another VETH.  The problem is that when veth is
given a packet to transmit, it is difficult to know where that packet
came from.

And, adding software checksumming to veth for every frame would be a huge
performance hit.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
