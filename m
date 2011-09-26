From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: intel 82599 multi-port performance
Date: Mon, 26 Sep 2011 09:04:59 -0700
Message-ID: <4E80A2AB.2040206@intel.com>
References: <4E805359.2080600@gmail.com> <4E808A41.8040902@genband.com> <4E809D59.10103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "J.Hwan.Kim" <j.hwan.kim99@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: frog1120@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50910 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751472Ab1IZQE7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Sep 2011 12:04:59 -0400
In-Reply-To: <4E809D59.10103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2011 08:42 AM, J.Hwan.Kim wrote:
> On 2011=EB=85=84 09=EC=9B=94 26=EC=9D=BC 23:20, Chris Friesen wrote:
>> On 09/26/2011 04:26 AM, J.Hwan Kim wrote:
>>> Hi, everyone
>>>
>>> Now, I'm testing a network card including intel 82599.
>>> In our experiment, with the driver modified with ixgbe and multi-po=
rt
>>> enabled,
>>
>> What do you mean by "modified with ixgbe and multi-port enabled"? Yo=
u
>> shouldn't need to do anything special to use both ports.
>>
>>> rx performance of each port with 10Gbps of 64bytes frame is
>>> a half than when only 1 port is used.
>>
>> Sounds like a cpu limitation. What is your cpu usage? How are your
>> interrupts routed? Are you using multiple rx queues?
>>
>
> Our server is XEON 2.4GHz with 8 cores.
> I'm using 4 RSS queues for each port and distributed it's interrupts=20
> to different cores respectively.
> I checked the CPU utilization with TOP, I guess ,it is not cpu=20
> imitation problem.

What kind of rates are you seeing on a single port versus multiple=20
ports?  There are multiple possibilities in terms of what could be=20
limiting your performance.

It sounds like you are using a single card, would that be correct?  If=20
you are running close to line rate on both ports this could be causing=20
you to saturate the PCIe x8 link.  If you have a second card available=20
you may want to try installing that in a secondary Gen2 PCIe slot and=20
seeing if you can improve the performance by using 2 PCIe slots instead=
=20
of one.

Also could you include your kernel config?  Certain features such as=20
Netfilter and IOMMU can have a significant impact on performance.

Thanks,

Alex
