From: Christopher Snook <csnook@redhat.com>
Subject: RFC: Nagle latency tuning
Date: Mon, 08 Sep 2008 17:56:05 -0400
Message-ID: <48C59F75.6030504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38921 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753743AbYIHV4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 17:56:31 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id m88LttI8028784
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2008 17:56:15 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m88Lti9m002829
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2008 17:55:44 -0400
Received: from bernoulli.usersys.redhat.com (dhcp-100-19-173.bos.redhat.com [10.16.19.173])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id m88Lthju005587
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2008 17:55:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey folks --

We frequently get requests from customers for a tunable to disable Nagle 
system-wide, to be bug-for-bug compatible with Solaris.  We routinely reject 
these requests, as letting naive TCP apps accidentally flood the network is 
considered harmful.  Still, it would be very nice if we could reduce 
Nagle-induced latencies system-wide, if we could do so without disabling Nagle 
completely.

If you write a multi-threaded app that sends lots of small messages across TCP 
sockets, and you do not use TCP_NODELAY, you'll often see 40 ms latencies as the 
network stack waits for more senders to fill an MTU-sized packet before 
transmitting.  Even worse, these apps may work fine across the LAN with a 1500 
MTU and then counterintuitively perform much worse over loopback with a 16436 MTU.

To combat this, many apps set TCP_NODELAY, often without the abundance of 
caution that option should entail.  Other apps leave it alone, and suffer 
accordingly.

If we could simply lower this latency, without changing the fundamental behavior 
of the TCP stack, it would be a great benefit to many latency-sensitive apps, 
and discourage the unnecessary use of TCP_NODELAY.

I'm afraid I don't know the TCP stack intimately enough to understand what side 
effects this might have.  Can someone more familiar with the nagle 
implementations please enlighten me on how this could be done, or why it 
shouldn't be?

-- Chris
