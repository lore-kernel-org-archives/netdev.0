From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next] bonding: lacp_port_id setting for 802.3ad
Date: Tue, 13 Aug 2013 09:07:40 +0800
Message-ID: <520986DC.4030805@huawei.com>
References: <5208C4BA.9020605@ivancso.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Krisztian Ivancso <github-ivan@ivancso.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:51850 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756249Ab3HMBIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 21:08:16 -0400
In-Reply-To: <5208C4BA.9020605@ivancso.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/12 19:19, Krisztian Ivancso wrote:
> The patch adds port id setting feature by lacp_port_id module
> parameter for 802.3ad ports.
> 
> Adding more linux boxes to a link aggregation makes possible to do
> load-balancing by using port channel load balancing of switch
> (eg. by source-dest-ip or src-ip).
> 
> It's essential to set the same MAC address to bonding interface and
> to set different port ids on different linux boxes for a
> working solution.
> 
> Possible use cases:
> 1. Redundant DNS servers with same IP address
> 2. Reverse proxies with same IP address
> 3. "multi-master" LVS
> 
> Beside redundancy it provides scalability, scalability depends on
> hardware capability.
> E.g. a LAG port with 4 members - linux LVS servers - using a Cisco
> switch/router splits traffic to ports equally by src IP (2-2-2-2).
> If a link fails, switch forwards traffic to 3 switch ports (3-3-3).
> It means you can utilize overall bandwith as much as 66% with full
> redundancy. It's better with 16% than using 2 master-slave LVS and
> you use just 1 IP and can handle 100% more peak traffic.
> 
> Using this feature with vPC (virtual portchannel) or similar solution
> it provides a physically redundant service from network devices
> to servers using the same IP address.
> 
> 
>>From 472fffa5a8f170daed9e4cc677af8e2560b86be2 Mon Sep 17 00:00:00 2001
> From: Krisztian Ivancso <github-ivan@ivancso.net>
> Date: Sun, 11 Aug 2013 20:30:44 +0200
> Subject: [PATCH net-next] bonding: lacp_port_id setting for 802.3ad ports
> 
> By setting this parameter to different values on different hosts
> it's possible to add more Linux boxes to the same Link Aggregation.
> 

I think the port id was made by negotiation,  if the negotiation failed, the bonding slave
could not get the port id you gave, which lie on the hardware message.
