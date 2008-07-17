From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 10/13]: net: Implement simple sw TX hashing.
Date: Thu, 17 Jul 2008 18:21:27 +0200
Message-ID: <487F7187.9060909@trash.net>
References: <20080710.035713.204601759.davem@davemloft.net> <20080717091641.18684218@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60273 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755204AbYGQQVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 12:21:31 -0400
In-Reply-To: <20080717091641.18684218@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Thu, 10 Jul 2008 03:57:13 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> It just xor hashes over IPv4/IPv6 addresses and ports of transport.
>>
>> The only assumption it makes is that skb_network_header() is set
>> correctly.
>>
>> +	switch (ip_proto) {
>> +	case IPPROTO_TCP:
>> +	case IPPROTO_UDP:
>> +	case IPPROTO_DCCP:
>> +	case IPPROTO_ESP:
>> +	case IPPROTO_AH:
>> +	case IPPROTO_SCTP:
>> +	case IPPROTO_UDPLITE:
>> +		hash ^= *ports;
>> +		break;
>> +
>> +	default:
>> +		break;
>> +	}
>> +
>> +	return hash % dev->real_num_tx_queues;
>> +}
> 
> What about VLAN's? and PPPoE?


Actually I think we could just make the number of tx queues of
virtual devices match the lower device and use the unencapsulated
packets for queue selection.

Of course that would require not to perform queue selection
again on the real device. For VLANs, macvlan etc. that don't
do any locking internally that would probably make sense.
Not sure about PPPoE.
