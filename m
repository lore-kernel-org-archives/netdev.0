From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: net: RFC ethtool 5-tuple filter set/get feature
Date: Mon, 15 Dec 2008 18:52:07 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0812151630570.10472@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18564 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589AbYLPCwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 21:52:15 -0500
Received: from ppwaskie-MOBL2.amr.corp.intel.com ([10.254.65.135])
	by plxs0284.pdx.intel.com (8.12.11.20060308/8.12.10/MailSET/Hub) with ESMTP id mBG2qCHv004661
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 18:52:13 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am looking at current methods to support adding 5-tuple filters to a 
network device.  3 methods I can see are 1) Creating a sysfs interface, 2) 
writing a custom application using netlink or some other interface, or 3) 
Adding support to ethtool.

The latest ethtool bits support the rxhash callbacks, allowing different 
Rx hashing methods to be enabled or disabled in Sun's Neptune device.  I 
would like to add similar options to ethtool to support features in 
current versions of igb hardware, and in future ixgbe hardware.

I'm soliciting feedback from the community before laying down code, in 
case someone has a better suggestion to solve this problem.  The data I 
need to pass through to the driver is: L4 source port, L4 destination 
port, Source address and Destination address (both IPv4 and IPv6), VLAN 
id, and a flexible layer 2 word (word anywhere in the L2 header) with 
masks for all of these.  I also need to pass through an Rx queue to assign 
the matching traffic to.  I'm also thinking of having the set operation 
take an add or remove command, so a filter can be popped out or added.

Any ideas or suggestions are appreciated.  I will work to get code out for 
review asap, but in the meantime any suggestions one way or another to 
possibly prevent lots of unnecessary work is appreciated.

Cheers,
-PJ Waskiewicz
<peter.p.waskiewicz.jr@intel.com>
