From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [net-next-2.6 PATCH 1/5] ixgbe: Allocate driver resources per
 NUMA node
Date: Tue, 19 Jan 2010 08:10:15 -0800
Message-ID: <F86E8680A7D9D74A99DC6345E35A6929502312B0@orsmsx503.amr.corp.intel.com>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
 <87y6k1dk5t.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Andi Kleen <andi@firstfloor.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24918 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752379Ab0ASQKV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 11:10:21 -0500
In-Reply-To: <87y6k1dk5t.fsf@basil.nowhere.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Andi Kleen [mailto:andi@firstfloor.org]
>Sent: Thursday, January 14, 2010 3:02 AM
>To: Kirsher, Jeffrey T
>Cc: davem@davemloft.net; netdev@vger.kernel.org; gospo@redhat.com;
>Waskiewicz Jr, Peter P
>Subject: Re: [net-next-2.6 PATCH 1/5] ixgbe: Allocate driver resources
>per NUMA node
>
>Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:
>>  enum ixbge_state_t {
>> diff --git a/drivers/net/ixgbe/ixgbe_main.c
>b/drivers/net/ixgbe/ixgbe_main.c
>> index 2ad754c..6895de7 100644
>> --- a/drivers/net/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ixgbe/ixgbe_main.c
>> @@ -3741,7 +3741,8 @@ static int ixgbe_alloc_q_vectors(struct
>ixgbe_adapter *adapter)
>>  	}
>>
>>  	for (q_idx = 0; q_idx < num_q_vectors; q_idx++) {
>> -		q_vector = kzalloc(sizeof(struct ixgbe_q_vector),
>GFP_KERNEL);
>> +		q_vector = kzalloc_node(sizeof(struct ixgbe_q_vector),
>> +		                        GFP_KERNEL, adapter->node);
>
>
>The problem of doing this is that the node might be full or have
>no memory and k*alloc_node will fail then.
>
>So you would need a fallback to be reliable (we probably should have a
>generic utility function for this somewhere, but we don't currently)

So you'd rather see us call kzalloc() if kzalloc_node() fails, instead of immediately failing out to err_out?

Thanks,
-PJ
