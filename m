From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: bonding questions: "replaying" call to set_multicast_list and sending
 IGMP doing Fail-Over
Date: Tue, 08 Aug 2006 17:05:04 +0300
Message-ID: <44D89A10.10701@voltaire.com>
References: <Pine.LNX.4.64.0608030815270.32510@zuben>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:26288 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP id S932595AbWHHOFO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 10:05:14 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0608030815270.32510@zuben>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Another question that bothers me is the bonding code multicast related 
behavior when it does fail-over.

 From what I see in bond_mc_swap(), set_multicast_list() is well 
handled: dev_mc_delete() is called for the old slave (so if in the 
future the old slave has a link, it will leave the multicast group) and 
dev_mc_add() is called for the active slave (so the active slave joins 
the multicast group).

As for sending IGMP, in bond_xmit_activebackup() i see the following 
comment: "Xmit IGMP frames on all slaves to ensure rapid fail-over
for multicast traffic on snooping switches".

As i don't see any buffering of the IGMP packets, i understand there's 
no "reply" of sending them during fail-over and this means that only 
when the router would do IGMP query on this node it will learn on the 
fail-over. Is it indeed what's going on? if i understand correct it 
would take some meaningful time for the fail-over to be externally 
visible in this respect.

Also assuming it does exactly what the comment says, another issue i see 
here is that in the case of not only the active_slave being UP, the code 
would TX the IGMP packets over > 1 slave, and hence multicast packets 
would be sent by the switch also to ports "connected to" non-active 
slaves, something which will hurt the system performance!?

Or.









