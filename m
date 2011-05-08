From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/2] net: Allow ethtool to set interface in loopback
 mode.
Date: Sun, 08 May 2011 16:00:07 -0700 (PDT)
Message-ID: <20110508.160007.212698129.davem@davemloft.net>
References: <1304471935-402-2-git-send-email-maheshb@google.com>
	<1304559011-15983-1-git-send-email-maheshb@google.com>
	<1304560369.3203.44.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, netdev@vger.kernel.org,
	mirq-linux@rere.qmqm.pl, therbert@google.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43583
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755542Ab1EHXAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 19:00:40 -0400
In-Reply-To: <1304560369.3203.44.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 05 May 2011 02:52:48 +0100

> On Wed, 2011-05-04 at 18:30 -0700, Mahesh Bandewar wrote:
>> This patch enables ethtool to set the loopback mode on a given interface.
>> By configuring the interface in loopback mode in conjunction with a policy
>> route / rule, a userland application can stress the egress / ingress path
>> exposing the flows of the change in progress and potentially help developer(s)
>> understand the impact of those changes without even sending a packet out
>> on the network.
>> 
>> Following set of commands illustrates one such example -
>>     a) ip -4 addr add 192.168.1.1/24 dev eth1
>>     b) ip -4 rule add from all iif eth1 lookup 250
>>     c) ip -4 route add local 0/0 dev lo proto kernel scope host table 250
>>     d) arp -Ds 192.168.1.100 eth1
>>     e) arp -Ds 192.168.1.200 eth1
>>     f) sysctl -w net.ipv4.ip_nonlocal_bind=1
>>     g) sysctl -w net.ipv4.conf.all.accept_local=1
>>     # Assuming that the machine has 8 cores
>>     h) taskset 000f netserver -L 192.168.1.200
>>     i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168.1.200 -l 30
>> 
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
