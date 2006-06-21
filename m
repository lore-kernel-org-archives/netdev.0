From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Wed, 21 Jun 2006 13:45:19 -0500
Message-ID: <20060621184519.10425.69175.stgit@stevo-desktop>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-227-247-53.sw.biz.rr.com ([24.227.247.53]:42212 "EHLO
	linux.local") by vger.kernel.org with ESMTP id S1751146AbWFUSpU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 14:45:20 -0400
Received: from [127.0.0.2] (localhost [127.0.0.1])
	by linux.local (Postfix) with ESMTP id 725E249018
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 13:45:19 -0500 (CDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch implements a mechanism that allows interested clients to
register for notification of certain network events. The intended use
is to allow RDMA devices (linux/drivers/infiniband) to be notified of
neighbour updates, ICMP redirects, path MTU changes, and route changes.

The reason these devices need update events is because they typically
cache this information in hardware and need to be notified when this
information has been updated.

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
