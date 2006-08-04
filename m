From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [RFC] driver adjusts qlen, increases CPU
Date: Fri, 4 Aug 2006 08:45:28 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0605100905150.1804@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:5155 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S1161258AbWHDPpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 11:45:30 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So we've recently put a bit of code in our e1000 driver to decrease the 
qlen based on the speed of the link.

On the surface it seems like a great idea.  A driver knows when the link 
speed changed, and having a 1000 packet deep queue (the default for most 
kernels now) on top of a 100Mb/s link (or 10Mb/s worst case for us) makes 
for a *lot* of latency if many packets are queued up in the qdisc.

Problem we've seen is that setting this shorter queue causes a large spike 
in cpu when transmitting using UDP:

100Mb/s link
txqueuelen: 1000 Throughput: 92.44 CPU: 5.00
txqueuelen: 100 Throughput: 93.80 CPU: 61.59

Is this expected? any comments?

Jesse
