From: Alan Stern <stern@rowland.harvard.edu>
Subject: Questions about IPsec and Netfilter
Date: Thu, 10 May 2007 10:36:14 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0705101019350.2600-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Networking development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:38369 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750930AbXEJOm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 10:42:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've got a few questions about the relationship between the IPsec 
implementation and Netfilter.

Q1: At what points during packet processing do the IPsec transformations 
occur?  In particular, which netfilter hooks do they come before and 
after?  And likewise, which routing operations do they come before and 
after?

Q2: When a packet using IPsec tunnel mode is encapsulated or 
de-encapsulated, does the newly-formed packet return to some earlier point 
in the stack for further netfilter processing or routing?  What about 
transport mode?

Q3: How can iptables rules determine whether they are dealing with a 
packet which has been de-encapsulated from (or encapsulated within) an 
IPsec wrapper?

Q4: Is it true that NAT-Traversal isn't implemented for transport mode?

In RFC 2401 (Security Architecture for the Internet Protocol), section 5
includes this text:

   As mentioned in Section 4.4.1 "The Security Policy Database (SPD)",
   the SPD must be consulted during the processing of all traffic
   (INBOUND and OUTBOUND), including non-IPsec traffic.  If no policy is
   found in the SPD that matches the packet (for either inbound or
   outbound traffic), the packet MUST be discarded.

But on Linux systems, by default the SPD is normally empty (as shown by
"setkey -DP") and all packets are allowed to pass unhindered.

Q5: Isn't this a violation of the RFC?  Or is there some implicit policy 
entry which accepts all packets without applying any security association?


Thanks for any answers.  I may think up more questions later...

Alan Stern

