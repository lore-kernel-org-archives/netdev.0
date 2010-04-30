From: Patrick McHardy <kaber@trash.net>
Subject: Re: ixgbe and mac-vlans problem
Date: Fri, 30 Apr 2010 14:24:23 +0200
Message-ID: <4BDACBF7.4050307@trash.net>
References: <4BDA07DB.8020206@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62455 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757867Ab0D3RtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:49:16 -0400
In-Reply-To: <4BDA07DB.8020206@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Hello!
> 
> We are seeing a strange problem with mac-vlans on top of an 82599 NIC
> (ixgbe)
> on a 2.6.31.y (plus patches) kernel.
> 
> Basically, we create 50 mac-vlans, with sequential MAC addresses and
> sequential
> IP addresses, and set up ip rules properly.
> 
> The issue is that only 10 or so of the mac-vlans receive other than
> broadcast packets.  The ixgbe NIC doesn't show PROMISC mode.

Not showing PROMISC is normal since this is going into promisc
when too many unicast addresses are configured is handled internally
by the drivers.

> If we manually turn on PROMISC mode on the physical ixgbe interface,
> then everything works properly.  I'm guessing the ixgbe NIC must
> have some filters that mac-vlan is trying to enable w/out turning on
> full PROMISC mode.  Is there any easy way to debug these filters
> to see if they are being properly configured?

Adding "#define DEBUG" to ixgbe_common.c should print some information
when unicast addresses are added.
