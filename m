From: Chris Caputo <ccaputo@alt.net>
Subject: possible problem with TSO and ip_queue
Date: Wed, 10 May 2006 18:44:30 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0605101815430.16614@nacho.alt.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Jakma <paul@clubi.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nacho.alt.net ([207.14.113.18]:30679 "HELO nacho.alt.net")
	by vger.kernel.org with SMTP id S932465AbWEJSod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 14:44:33 -0400
To: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Environment is 2.6.16.9 with e1000 NICs.

Paul and I (as part of the Quagga project) are working on a user mode 
method for doing BGP MD5 checksums using ip_queue.  All is working except 
when TSO is enabled I am seeing some problems.

It appears that when TSO is enabled, ip_queue can be used to manipulate 
packets that have a size higher than the particular MSS (and MTU) for a 
TCP stream.

This results in a larger than MSS packet going out to the NIC with a TCP 
MD5 checksum, getting split by the NIC to match the MTU of the LAN, and 
then being received as multiple packets with incorrect MD5 checksums.

Then a retransmit with a smaller/correct MSS happens and the packets are 
received with valid MD5 checksums.

So in effect, the data eventually makes it across the link, but it is sent 
twice, once with invalid checksums and once with valid checksums, and 
throughput is slow.

When TSO is disabled, things happen as they should.

Does this sound like a bug or by design?

Does it make sense that ip_queue mangled packets be subjected to TSO, 
given that the TCP header can be messed with by the user mode code?

Chris
