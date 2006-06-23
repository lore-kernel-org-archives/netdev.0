From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH REPOST 0/2][RFC] Network Event Notifier Mechanism
Date: Fri, 23 Jun 2006 15:19:18 -0500
Message-ID: <20060623201918.32482.89765.stgit@stevo-desktop>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-227-247-53.sw.biz.rr.com ([24.227.247.53]:52133 "EHLO
	linux.local") by vger.kernel.org with ESMTP id S1752026AbWFWUTT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 16:19:19 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


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

This approach is one of many possibilities and may be preferred because it
uses an existing notification mechanism that has precedent in the stack.
An alternative would be to add a netdev method to notify affect devices
of these events.

This code does not yet implement path MTU change because the number of
places in which this value is updated is large and if this mechanism
seems reasonable, it would be probably be best to funnel these updates
through a single function.

We would like to get this or similar functionality included in 2.6.19
and request comments.

This patchset consists of 2 patches:

1) New files implementing the Network Event Notifier
2) Core network changes to generate network event notifications

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
