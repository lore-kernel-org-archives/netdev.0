From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering
 support for passthru mode
Date: Mon, 12 Sep 2011 10:23:24 -0700
Message-ID: <CA938E1C.33F00%roprabhu@cisco.com>
References: <4E6D8AF3.7080406@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, <netdev@vger.kernel.org>,
	<dragos.tatulea@gmail.com>, <arnd@arndb.de>, <dwang2@cisco.com>,
	<benve@cisco.com>, <kaber@trash.net>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <mchan@broadcom.com>,
	<kvm@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:15339 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951Ab1ILRX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 13:23:26 -0400
In-Reply-To: <4E6D8AF3.7080406@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On 9/11/11 9:30 PM, "Sridhar Samudrala" <sri@us.ibm.com> wrote:

> On 9/11/2011 6:18 AM, Roopa Prabhu wrote:
>> 
>> 
>> On 9/11/11 2:44 AM, "Michael S. Tsirkin"<mst@redhat.com>  wrote:
>> 
>>>> AFAIK, though it might maintain a single filter table space in hw, hw does
>>>> know which filter belongs to which VF. And the OS driver does not need to
>>>> do
>>>> anything special. The VF driver exposes a VF netdev. And any uc/mc
>>>> addresses
>>>> registered with a VF netdev are registered with the hw by the driver. And
>>>> hw
>>>> will filter and send only pkts that the VF has expressed interest in.
>>>> 
>>>> No special filter partitioning in hw is required.
>>>> 
>>>> Thanks,
>>>> Roopa
>>> Yes, but what I mean is, if the size of the single filter table
>>> is limited, we need to decide how many addresses is
>>> each guest allowed. If we let one guest ask for
>>> as many as it wants, it can lock others out.
>> Yes true. In these cases ie when the number of unicast addresses being
>> registered is more than it can handle, The VF driver will put the VF  in
>> promiscuous mode (Or at least its supposed to do. I think all drivers do
>> that).
>> 
> What does putting VF in promiscuous mode mean?  How can the NIC decide
> which set
> of mac addresses are passed to the VF? Does it mean VF sees all the
> packets received
> by the NIC including packets destined for other VFs/PF?
> 
Yes I think so. After your question I looked at 2 other  VF drivers and
looks like they return error if num unicast addresses exceeds the number
supported by hw and don't put the VF in promiscuous mode. But one could put
the VF in promiscuous mode by changing IFF_FLAGS I think.

The original in-kernel passthru mode code puts the VF in promiscuous mode by
default. Am assuming that works well with other sriov cards you got a chance
to try out with.

Thanks,
Roopa
