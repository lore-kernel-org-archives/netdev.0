From: Jeff Garzik <jeff@garzik.org>
Subject: Re: ethtool: Expand ethtool_cmd.speed to 32 bits
Date: Mon, 28 Jul 2008 14:36:35 -0400
Message-ID: <488E11B3.6070901@garzik.org>
References: <487D1C4C.9080103@hp.com> <20080715.152758.193724361.davem@davemloft.net> <20080716064709.GA2424@potty.ifup.org> <20080715.154303.193684908.davem@davemloft.net> <20080728171148.GJ5378@potty.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org, jgarzik@pobox.com
To: Brandon Philips <brandon@ifup.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47032 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750851AbYG1Sgl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2008 14:36:41 -0400
In-Reply-To: <20080728171148.GJ5378@potty.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandon Philips wrote:
> On 15:43 Tue 15 Jul 2008, David Miller wrote:
>> From: Brandon Philips <brandon@ifup.org>
>> Date: Tue, 15 Jul 2008 23:47:09 -0700
>>
>>> On 15:27 Tue 15 Jul 2008, David Miller wrote:
>>>> From: Rick Jones <rick.jones2@hp.com>
>>>> Date: Tue, 15 Jul 2008 14:53:16 -0700
>>>>
>>>>> Brandon Philips wrote:
>>>>>> Introduce the speed_hi field to ethtool_cmd, using the reserved space,
>>>>>> to expand the speed field to 2^32 Megabits/second.
>>>>>>
>>>>>> Making this field expansion now gives us plenty of time to fix up the
>>>>>> user-space pieces that use SIOCETHTOOL before hardware faster than 64
>>>>>> Gb/s is available.
>>>>>>
>>>>>> Signed-off-by: Brandon Philips <bphilips@suse.de>
>>>>>>
>>>>>> ---
>>>>>>  include/linux/ethtool.h |   17 ++++++++++++++++-
>>>>>>  1 file changed, 16 insertions(+), 1 deletion(-)
>>>>>>
>>>>>> Index: linux-2.6/include/linux/ethtool.h
>>>>>> ===================================================================
>>>>>> --- linux-2.6.orig/include/linux/ethtool.h
>>>>>> +++ linux-2.6/include/linux/ethtool.h
>>>>>> @@ -27,9 +27,24 @@ struct ethtool_cmd {
>>>>>>  	__u8	autoneg;	/* Enable or disable autonegotiation */
>>>>>>  	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
>>>>>>  	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
>>>>>> -	__u32	reserved[4];
>>>>>> +	__u16	speed_hi;
>>>>>> +	__u16	reserved2;
>>>>>> +	__u32	reserved[3];
>>>>>>  };
>>>>> I certainly agree with the concept of preparing for faster NICs.  Are 
>>>>> bits in that structure sufficiently precious to go the split route, or 
>>>>> would it be cleaner to just grab a contiguous 32 bits from the structure?
>>>> That's less space we can use to make similar expansions.
>>>>
>>>> And we have to keep the existing u16 chunk there anyways, because existing
>>>> applications are only going to provide that part.
>>> Agreed.  Can this be queued for 2.6.27 then?
>> Jeff?
> 
> Has this been merged somewhere?  I just checked net-2.6 and net-next and
> didn't see it.

Sorry, this thread was buried deep in an inbox.  Rescued and queued.

	Jeff




