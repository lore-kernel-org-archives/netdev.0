From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH Round 3 0/2][RFC] Network Event Notifier Mechanism
Date: Tue, 27 Jun 2006 15:50:50 -0500
Message-ID: <20060627205050.30723.25753.stgit@stevo-desktop>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-227-247-53.sw.biz.rr.com ([24.227.247.53]:47792 "EHLO
	linux.local") by vger.kernel.org with ESMTP id S1030346AbWF0Uuv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:50:51 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


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

TODO: 

- review feedback changes, if any
- more testing
- retest with RDMA NIC

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

This patchset consists of 2 patches:

1) New files implementing the Network Event Notifier
2) Core network changes to generate network event notifications

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
