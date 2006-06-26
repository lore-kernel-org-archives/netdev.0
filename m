From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH Round 2 0/2][RFC] Network Event Notifier Mechanism
Date: Mon, 26 Jun 2006 15:36:38 -0500
Message-ID: <20060626203638.19083.71231.stgit@stevo-desktop>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-227-247-53.sw.biz.rr.com ([24.227.247.53]:29586 "EHLO
	linux.local") by vger.kernel.org with ESMTP id S932090AbWFZUgj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 16:36:39 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Round 2 Changes:

- cleaned up event structures per review feedback.
- began integration with netlink (see neighbour changes in patch 2).
- added IPv6 support.

STILL TODO:

- PMTU events/netlink
- Redirect netlink (need to define a new netlink message for this).

Questions:

- this patch is enabling some of the functionality that was under
  CONFIG_ARPD.  Should I remove the CONFIG_ARPD stuff, leave it as-is
  or what?

- what about support for other afs?  Should I hook AF_DECnet?  IPX? Or is
  AF_INET and AF_INET6 sufficient?

- I added a new RTM type in rtnetlink.h for neighbour change netlink
  messages.  I suspect I did it wrong...


------

This patch implements a mechanism that allows interested clients to
register for notification of certain network events. The intended use
is to allow RDMA devices (linux/drivers/infiniband) to be notified of
neighbour updates, ICMP redirects, path MTU changes, and route changes.

The reason these devices need update events is because they typically
cache this information in hardware and need to be notified when this
information has been updated.

The key events of interest are:

- neighbour mac address change 
- routing redirect (the next hop neighbour changes for a dst_entry)
- path mtu change (the patch mtu for a dst_entry changes).
- route add/deletes

NOTE: Network events are also passed up to user space via netlink.

We would like to get this or similar functionality included in 2.6.19
and request comments.

This patchset consists of 2 patches:

1) New files implementing the Network Event Notifier
2) Core network changes to generate network event notifications

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
