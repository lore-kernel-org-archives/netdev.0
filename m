From: Krisztian Ivancso <github-ivan@ivancso.net>
Subject: Re: [PATCH net-next] bonding: lacp_port_id setting for 802.3ad
Date: Tue, 13 Aug 2013 11:20:09 +0200
Message-ID: <5209FA49.6030800@ivancso.net>
References: <5208C4BA.9020605@ivancso.net> <520986DC.4030805@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhandler.info ([217.116.47.195]:43429 "EHLO mailhandler.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756202Ab3HMJUO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Aug 2013 05:20:14 -0400
In-Reply-To: <520986DC.4030805@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/13/2013 03:07 AM, Ding Tianhong wrote:
> On 2013/8/12 19:19, Krisztian Ivancso wrote:
>> >From 472fffa5a8f170daed9e4cc677af8e2560b86be2 Mon Sep 17 00:00:00 2001
>> From: Krisztian Ivancso <github-ivan@ivancso.net>
>> Date: Sun, 11 Aug 2013 20:30:44 +0200
>> Subject: [PATCH net-next] bonding: lacp_port_id setting for 802.3ad ports
>>
>> By setting this parameter to different values on different hosts
>> it's possible to add more Linux boxes to the same Link Aggregation.
>>
> 
> I think the port id was made by negotiation,  if the negotiation failed, the bonding slave
> could not get the port id you gave, which lie on the hardware message.

Port id is currently preset to 1 in bonding driver for first slave.
(SLAVE_AD_INFO(new_slave).id = 1; this id is used as
actor_port_number in slave initialization)
Port id parameter modifies just this starting value and new slaves
get incremented port ids as in current implementation.

As I see in documentation port id (port number) set by each
participating devices by it's own and given values are used by
the other side.

In Cisco and Juniper documentations port id is mentioned, the value
is derived from port number which is unique within a switch.

Cisco:
> LACP uses the port priority with the port number to form the
> port identifier.

Juniper:
> The LACP port ID consists of the port priority as the two
> most-significant octets and the port number as the two
> least-significant octets.


Cisco:
> The LACP system ID is the combination of the LACP system priority
> value and the MAC address.

This is why we need to use the same MAC for all participating bonding
device in different linux boxes.


The solution is tested with Cisco devices.
