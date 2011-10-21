From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] rtnetlink: Add missing manual netlink notification in dev_change_net_namespaces
Date: Fri, 21 Oct 2011 09:24:20 -0700
Message-ID: <m1ty72l3d7.fsf_-_@fess.ebiederm.org>
References: <CAChaegkomwjL0X7HnfLi1XH26jDKOL6fCgjfms67cjjU4gRXPg@mail.gmail.com>
	<m1r54s8lq4.fsf@fess.ebiederm.org>
	<CAChaegm2d3LywMAcq66PgPZwF5Fu=_zuqcTh8VdCG6zvhyPJXQ@mail.gmail.com>
	<CAChaeg=1WSU0webhYDpQcnq3cJje17FQ5Z8rypD8sdkyzcLT-g@mail.gmail.com>
	<m14o1e71qe.fsf@fess.ebiederm.org>
	<CAChaegnHchLT0BV-_RaPT2-J3ZLin_U1x8X0KBi7ku1MArug1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net,
	David Lamparter <equinox@diac24.net>,
	Renato Westphal <renatowestphal@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:36037 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408Ab1JUQXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 12:23:51 -0400
In-Reply-To: <CAChaegnHchLT0BV-_RaPT2-J3ZLin_U1x8X0KBi7ku1MArug1g@mail.gmail.com>
	(Renato Westphal's message of "Fri, 19 Aug 2011 11:38:33 -0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Renato Westphal noticed that since commit a2835763e130c343ace5320c20d33c281e7097b7
"rtnetlink: handle rtnl_link netlink notifications manually" was merged
we no longer send a netlink message when a networking device is moved
from one network namespace to another.

Fix this by adding the missing manual notification in dev_change_net_namespaces.

Since all network devices that are processed by dev_change_net_namspaces are
in the initialized state the complicated tests that guard the manual
rtmsg_ifinfo calls in rollback_registered and register_netdevice are
unnecessary and we can just perform a plain notification.

Cc: stable@kernel.org
Tested-by: Renato Westphal <renatowestphal@gmail.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/dev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ad5d702..b7ba81a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6266,6 +6266,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	*/
 	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
 	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
+	rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
 
 	/*
 	 *	Flush the unicast and multicast chains
-- 
1.7.2.5
