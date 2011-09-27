From: "J.Hwan Kim" <frog1120@gmail.com>
Subject: Re: intel 82599 multi-port performance
Date: Tue, 27 Sep 2011 09:45:02 +0900
Message-ID: <4E811C8E.8020508@gmail.com>
References: <4E805359.2080600@gmail.com> <4E808A41.8040902@genband.com> <4E809D59.10103@gmail.com> <4E80A2AB.2040206@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:36333 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765Ab1I0ApI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 20:45:08 -0400
Received: by pzk1 with SMTP id 1so16070154pzk.1
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 17:45:07 -0700 (PDT)
In-Reply-To: <4E80A2AB.2040206@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011=EB=85=84 09=EC=9B=94 27=EC=9D=BC 01:04, Alexander Duyck wrote:
> On 09/26/2011 08:42 AM, J.Hwan.Kim wrote:
>> On 2011=EB=85=84 09=EC=9B=94 26=EC=9D=BC 23:20, Chris Friesen wrote:
>>> On 09/26/2011 04:26 AM, J.Hwan Kim wrote:
>>>> Hi, everyone
>>>>
>>>> Now, I'm testing a network card including intel 82599.
>>>> In our experiment, with the driver modified with ixgbe and multi-p=
ort
>>>> enabled,
>>>
>>> What do you mean by "modified with ixgbe and multi-port enabled"? Y=
ou
>>> shouldn't need to do anything special to use both ports.
>>>
>>>> rx performance of each port with 10Gbps of 64bytes frame is
>>>> a half than when only 1 port is used.
>>>
>>> Sounds like a cpu limitation. What is your cpu usage? How are your
>>> interrupts routed? Are you using multiple rx queues?
>>>
>>
>> Our server is XEON 2.4GHz with 8 cores.
>> I'm using 4 RSS queues for each port and distributed it's interrupts=
=20
>> to different cores respectively.
>> I checked the CPU utilization with TOP, I guess ,it is not cpu=20
>> imitation problem.
>
> What kind of rates are you seeing on a single port versus multiple=20
> ports?  There are multiple possibilities in terms of what could be=20
> limiting your performance.
>

I tested the 10G - 64byte frames.
With ixgbe-modified driver, in single port, 92% of packet received in=20
driver level and in 2 port we received around 42% packets.

> It sounds like you are using a single card, would that be correct?

Yes, I tested a single card with 2 ports.

> If you are running close to line rate on both ports this could be=20
> causing you to saturate the PCIe x8 link.  If you have a second card=20
> available you may want to try installing that in a secondary Gen2 PCI=
e=20
> slot and seeing if you can improve the performance by using 2 PCIe=20
> slots instead of one.

I tested it also, if it is tested with 2 card, it seems that the=20
performance of each port is almost same with a single port. (maximum=20
performance)
