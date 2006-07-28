From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH Round 5 0/3] Network Event Notifier Mechanism
Date: Fri, 28 Jul 2006 13:28:49 -0500
Message-ID: <20060728182849.14325.62898.stgit@stevo-desktop>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:32228 "EHLO
	linux.local") by vger.kernel.org with ESMTP id S1161215AbWG1S2z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 14:28:55 -0400
To: davem@davemloft.net, rdreier@cisco.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Dave/Roland, is this patchset about ready to go?

Round 5 Changes:

- removed user-mode support
- removed route add/del events.

------

This patch implements a mechanism that allows interested clients to
register for notification of certain network events. The intended use
is to allow RDMA devices (linux/drivers/infiniband) to be notified of
neighbour updates, ICMP redirects, and path MTU changes.

RDMA devices need these network events because they typically
cache this information in hardware and need to be notified
when it changes.  To learn about RDMA internet protocols, see:
http://www.ietf.org/html.charters/rddp-charter.html.

The key events of interest are:

- neighbour mac address change 
- routing redirect (the next hop neighbour changes for a dst_entry)
- path mtu change (the path mtu for a dst_entry changes).

This patchset consists of 3 patches:

1) New files implementing the Network Event Notifier
2) Core network changes to generate netevents
3) Cleanup ib_addr modules to use the netevent patch

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
