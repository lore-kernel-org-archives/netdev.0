From: Roland Dreier <rdreier@cisco.com>
Subject: Re: setsockopt()
Date: Mon, 07 Jul 2008 23:29:31 -0700
Message-ID: <adar6a4x510.fsf@cisco.com>
References: <48725DFE.6000504@citi.umich.edu>
	<20080707142408.43aa2a2e@extreme> <48728B09.1050801@citi.umich.edu>
	<20080707.144912.76654646.davem@davemloft.net>
	<20080708045443.GA7726@2ka.mipt.ru>
	<20080708020235.388a7bd5.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu,
	bfields@fieldses.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:15044 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbYGHG3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 02:29:32 -0400
In-Reply-To: <20080708020235.388a7bd5.billfink@mindspring.com> (Bill Fink's
	message of "Tue, 8 Jul 2008 02:02:35 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interesting... I'd not tried nuttcp before, and on my testbed, which is
a very high-bandwidth, low-RTT network (IP-over-InfiniBand with DDR IB,
so the network is capable of 16 Gbps, and the RTT is ~25 microseconds),
the difference between autotuning and not for nuttcp is huge (testing
with 2.6.26-rc8 plus some pending 2.6.27 patches that add checksum
offload, LSO and LRO to the IP-over-IB driver):

nuttcp -T30 -i1 ends up with:

14465.0625 MB /  30.01 sec = 4043.6073 Mbps 82 %TX 2 %RX

while setting the window even to 128 KB with
nuttcp -w128k -T30 -i1 ends up with:

36416.8125 MB /  30.00 sec = 10182.8137 Mbps 90 %TX 96 %RX

so it's a factor of 2.5 with nuttcp.  I've never seen other apps behave
like that -- for example NPtcp (netpipe) only gets slower when
explicitly setting the window size.

Strange...
