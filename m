From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Sat, 15 Jan 2011 01:51:39 +0300
Message-ID: <4D30D37B.6090908@yandex-team.ru>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elephant.yandex.ru ([77.88.34.7]:24232 "EHLO elephant.yandex.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752315Ab1ANXCU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 18:02:20 -0500
In-Reply-To: <17405.1295036019@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Jay Vosburgh wrote:

> 	This is a violation of the 802.3ad (now 802.1ax) standard, 5.2.1
> (f), which requires that all frames of a given "conversation" are passed
> to a single port.
> 
> 	The existing layer3+4 hash has a similar problem (that it may
> send packets from a conversation to multiple ports), but for that case
> it's an unlikely exception (only in the case of IP fragmentation), but
> here it's the norm.  At a minimum, this must be clearly documented.
> 
> 	Also, what does a round robin in 802.3ad provide that the
> existing round robin does not?  My presumption is that you're looking to
> get the aggregator autoconfiguration that 802.3ad provides, but you
> don't say.
> 
> 	I don't necessarily think this is a bad cheat (round robining on
> 802.3ad as an explicit non-standard extension), since everybody wants to
> stripe their traffic across multiple slaves.  I've given some thought to
> making round robin into just another hash mode, but this also does some
> magic to the MAC addresses of the outgoing frames (more on that below).
Yes, I am resetting MAC addresses when transmitting packets to have 
switch to put packets into different ports of the receiving etherchannel.
I am using this patch to provide full-mesh ISCSI connectivity between at 
least 4 hosts (all hosts of course are in same ethernet segment) and 
every host is connected with aggregate link with 4 slaves(usually).
Using round-robin I provide near-equal load striping when transmitting, 
using MAC address magic I force switch to stripe packets over all slave 
links in destination port-channel(when number of rx-ing slaves is equal 
to number ot tx-ing slaves and is even). So I am able to utilize all 
slaves for tx and for rx up to maximum capacity; besides I am getting L2 
link failure detection (and load rebalancing), which is (in my opinion) 
much faster and robust than L3 or than dm-multipath provides.
It's my idea with the patch
> 

> 
> 	This is the code that resets the MAC header as described above.
> It doesn't quite match the documentation, since it only resets the MAC
> for ETH_P_IP packets.
Yes, I really meant that my patch applies to ETH_P_IP packets and I've 
missed that from documentation I wrote.
> 

> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 

-- 
Best regards,

Oleg Ukhno

