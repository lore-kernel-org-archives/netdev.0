From: "Chris Friesen" <cfriesen@nortel.com>
Subject: when using arp monitoring with bonding, why use broadcast arps?
Date: Tue, 04 Dec 2007 11:27:24 -0600
Message-ID: <47558DFC.5050601@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753796AbXLDR1v@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We have a network with a number of nodes using bonding with arp 
monitoring.  The arp interval is set to 100ms.

Unfortunately, the bonding code sends the arp packets to the hardware 
broadcast address, which means that the number of these arp packets seen 
by each node goes up with the number of nodes on the network.

One of the nodes has a fairly low-powered cpu and handles most things in 
microengine code, but arp packets get handled in software.  All these 
broadcast arps slow this node down noticeably.

Is there any particular reason why the bonding code couldn't use unicast 
arp packets if the "arp_ip_target" has a valid entry in the sender's arp 
table?

Thanks,

Chris
