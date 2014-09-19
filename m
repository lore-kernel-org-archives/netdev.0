From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: allow macvlans to move to net namespace
Date: Fri, 19 Sep 2014 17:07:50 -0400 (EDT)
Message-ID: <20140919.170750.2115030779931675406.davem@davemloft.net>
References: <20140917181227.09F4E480087@fruggeri-Arora18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fruggeri@arista.com, fw@strlen.de,
	chenweilong@huawei.com
To: fruggeri@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757740AbaISVHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:07:52 -0400
In-Reply-To: <20140917181227.09F4E480087@fruggeri-Arora18.sjc.aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fruggeri@aristanetworks.com (Francesco Ruggeri)
Date: Wed, 17 Sep 2014 11:12:27 -0700

> From 6dad8398aee7fec77838ad591871745508ed481d Mon Sep 17 00:00:00 2001
> From: Francesco Ruggeri <fruggeri@arista.com>
> Date: Wed, 17 Sep 2014 10:40:44 -0700
> Subject: [PATCH 1/1] net: allow macvlans to move to net namespace
> 
> I cannot move a macvlan interface created on top of a bonding interface
> to a different namespace:
> 
> % ip netns add dummy0
> % ip link add link bond0 mac0 type macvlan
> % ip link set mac0 netns dummy0
> RTNETLINK answers: Invalid argument
> %
> 
> The problem seems to be that commit f9399814927a ("bonding: Don't allow
> bond devices to change network namespaces.") sets NETIF_F_NETNS_LOCAL
> on bonding interfaces, and commit 797f87f83b60 ("macvlan: fix netdev
> feature propagation from lower device") causes macvlan interfaces
> to inherit its features from the lower device.
> 
> NETIF_F_NETNS_LOCAL should not be inherited from the lower device
> by a macvlan.
> Patch tested on 3.16.
> 
> Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>

Applied and queued up for -stable, thanks.
