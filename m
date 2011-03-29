From: Stephen Hemminger <shemminger@vyatta.com>
Subject: ethtool physical identify vs netlink locking?
Date: Tue, 29 Mar 2011 13:52:52 -0700
Message-ID: <20110329135252.116bf5e0@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57248 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754003Ab1C2Uw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2011 16:52:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right now if an administrator uses the ethtool function to identify network
interface, the netlink lock can be held indefinitely. In other words, doing
"ethtool -p eth1" will stop all other netlink activity. This is bad, imagine
the case of an operator doing that to find a NIC in a rack, and because of
the netlink lockout all routing daemon activity stops.

There are several possible solutions but most involve fixing all the device
drivers (24). Options:

1. Have device driver drop and reacquire rtnl() while blinking
2. Have ethtool core drop rtnl before calling device driver
3. Add per-device ethtool rtnl lock

#1 is the least disruption
#2 means additional locking maybe required for each device driver
#3 seems like excessive overhead.

Comments?
