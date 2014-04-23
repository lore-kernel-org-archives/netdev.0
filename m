From: David Gibson <david@gibson.dropbear.id.au>
Subject: [0/2] Fix problems with with IFLA_VF_PORTS
Date: Wed, 23 Apr 2014 17:21:03 +1000
Message-ID: <1398237665-26980-1-git-send-email-david@gibson.dropbear.id.au>
Cc: ssujith@cisco.com, neepatel@cisco.com, benve@cisco.com,
	davem@davemloft.net, ben@decadent.org.uk,
	govindarajulu90@gmail.com, gregory.v.rose@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:49135 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756781AbaDWHVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 03:21:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've had a customer encounter a problem with getifaddrs(3) freezing up
on a system with a Cisco enic device.

I've discovered that the problem is caused by an enic device with a
large number of SR-IOV virtual functions overflowing the normal sized
packet buffer for netlink, leading to interfaces not being reported
from an RTM_GETLINK request.

The first patch here just makes the problem easier to locate if it
occurs again in a different way, by adding a WARN_ON() when we run out
of room in a netlink packet in this manner.

The second patch actually fixes the problem, by only reporting
IFLA_VF_PORTS information when the RTEXT_FILTER_VF flag is specified.
