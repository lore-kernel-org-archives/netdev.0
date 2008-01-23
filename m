From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [IPV4 0/9] TRIE performance patches
Date: Wed, 23 Jan 2008 15:06:47 +0100
Message-ID: <18327.18935.137799.285515@robur.slu.se>
References: <20080122233733.404145234@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:38481 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751536AbYAWOGq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 09:06:46 -0500
In-Reply-To: <20080122233733.404145234@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen Hemminger writes:

 > Time to handle a full BGP load (163K of routes).
 > 
 > Before:		Load		Dump		Flush
 >
 > kmem_cache	3.8		13.0		7.2
 > iter		3.9		12.3		6.9
 > unordered	3.1		11.9		4.9
 > find_node	3.1		 0.3		1.2

 I certainly like the speed but what will we brake when
 we don't return in longest prefix order?

labb:/# ip r
default via 10.10.10.1 dev eth0 
5.0.0.0/8 via 192.168.2.2 dev eth3 
10.10.10.0/24 dev eth0  proto kernel  scope link  src 10.10.10.2 
10.10.11.0/24 dev eth1  proto kernel  scope link  src 10.10.11.1 
11.0.0.0/8 via 10.10.11.2 dev eth1 
192.168.1.0/24 dev eth2  proto kernel  scope link  src 192.168.1.2 
192.168.2.0/24 dev eth3  proto kernel  scope link  src 192.168.2.1 

labb:/# ip route list match 10.10.10.1
default via 10.10.10.1 dev eth0 
10.10.10.0/24 dev eth0  proto kernel  scope link  src 10.10.10.2 
labb:/# 

Maybe the unordered dump can be ordered cheaply...

Cheers.
				--ro

