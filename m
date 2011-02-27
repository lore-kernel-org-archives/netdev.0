From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH nex-next] netdevice: make initial group visible to userspace
Date: Sun, 27 Feb 2011 10:39:12 +0200
Message-ID: <20110227083911.GA29638@cormyr>
References: <1296671021-24421-1-git-send-email-ddvlad@rosedu.org>
 <1296671021-24421-2-git-send-email-ddvlad@rosedu.org>
 <20110225124345.0d691789@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:52855 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751419Ab1B0ImE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Feb 2011 03:42:04 -0500
Content-Disposition: inline
In-Reply-To: <20110225124345.0d691789@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 25, 2011 at 12:43:45PM -0800, Stephen Hemminger wrote:
> On Wed,  2 Feb 2011 20:23:40 +0200
> Vlad Dogaru <ddvlad@rosedu.org> wrote:
> 
> > User can specify device group to list by using the group keyword:
> > 
> > 	ip link show group test
> > 
> > If no group is specified, 0 (default) is implied.
> > 
> > Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
> 
> I applied this to net-next for iproute2
> but INIT_NETDEV_GROUP is in a part of netdevice.h that is not exported 
> (ie inside #ifdef KERNEL).

Sorry, here is a patch for net-next that fixes the issue:


[PATCH net-next] netdevice: make initial group visible to userspace

INIT_NETDEV_GROUP is needed by userspace, move it outside __KERNEL__
guards.

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 include/linux/netdevice.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ffe56c1..8be4056 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -75,9 +75,6 @@ struct wireless_dev;
 #define NET_RX_SUCCESS		0	/* keep 'em coming, baby */
 #define NET_RX_DROP		1	/* packet dropped */
 
-/* Initial net device group. All devices belong to group 0 by default. */
-#define INIT_NETDEV_GROUP	0
-
 /*
  * Transmit return codes: transmit return codes originate from three different
  * namespaces:
@@ -141,6 +138,9 @@ static inline bool dev_xmit_complete(int rc)
 
 #define MAX_ADDR_LEN	32		/* Largest hardware address length */
 
+/* Initial net device group. All devices belong to group 0 by default. */
+#define INIT_NETDEV_GROUP	0
+
 #ifdef  __KERNEL__
 /*
  *	Compute the worst case header length according to the protocols
-- 
1.7.1

