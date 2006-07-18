From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH Round 4 0/3][RFC] Network Event Notifier Mechanism
Date: Tue, 18 Jul 2006 13:48:47 -0500
Message-ID: <20060718184847.25455.88191.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:30173 "EHLO
	dell3.ogc.int") by vger.kernel.org with ESMTP id S932354AbWGRSss
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 14:48:48 -0400
To: davem@davemloft.net, rdreier@cisco.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



All,

I'm posting this one more time for a definitive decision on pulling in
this netevent notifier patch.

I've included in this patchset changes to the Infiniband Core to use
netevents instead of packet snooping to discover IPoIB ARP changes.
See patch 3/3 for the Infiniband changes.

Thanks,

Steve.


Round 4 Changes:

- changed drivers/infiniband/core/addr.c to use netevents for 
  discovering IPoIB ARP events.

Round 3 Changes:

- changed netlink msg for neighbour change to (RTM_NEIGHUPD)
- added netlink msg for PMTU change events (RTM_ROUTEUPD)
- added netlink messages for redirect (RTM_DELROUTE + RTM_NEWROUTE)
- tested neighbour change events via netlink for ipv4 and ipv6.
- tested redirect change events via netlink for ipv4.

Round 2 Changes:

- cleaned up event structures per review feedback.
- began integration with netlink (see neighbour changes in patch 2).
- added IPv6 support.

------

This patch implements a mechanism that allows interested clients to
register for notification of certain network events. The intended use
is to allow RDMA devices (linux/drivers/infiniband) to be notified of
neighbour updates, ICMP redirects, path MTU changes, and route changes.

The reason these devices need update events is because they typically
cache this information in hardware and need to be notified when this
information has been updated.  For information on RDMA protocols, see:
http://www.ietf.org/html.charters/rddp-charter.html.

The key events of interest are:

- neighbour mac address change 
- routing redirect (the next hop neighbour changes for a dst_entry)
- path mtu change (the path mtu for a dst_entry changes).
- route add/deletes

NOTE: These new netevents are also passed up to user space via netlink.

We would like to get this or similar functionality included in 2.6.19
and request comments.

This patchset consists of 3 patches:

1) New files implementing the Network Event Notifier
2) Core network changes to generate network event notifications
3) Cleanup ib_addr modules to use the netevent patch

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
