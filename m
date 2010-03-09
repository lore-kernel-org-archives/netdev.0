From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH 3/3] bridge: forbid slave devices to change it's
 type
Date: Tue, 9 Mar 2010 15:19:47 +0100
Message-ID: <20100309141947.GE2783@psychotron.lab.eng.brq.redhat.com>
References: <20100309141724.GB2783@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	davem@davemloft.net, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751024Ab0CIOUe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Mar 2010 09:20:34 -0500
Content-Disposition: inline
In-Reply-To: <20100309141724.GB2783@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not desired for underlaying devices to change type. At the time, there is
for example possible to have bond with changed type from Ethernet to Infiniband
as a port of a bridge. This patch fixes this.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/bridge/br_notify.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 763a3ec..a68c692 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -82,6 +82,9 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 	case NETDEV_UNREGISTER:
 		br_del_if(br, dev);
 		break;
+
+	case NETDEV_TYPE_CHNG_START:
+		return NOTIFY_BAD;
 	}
 
 	/* Events that may cause spanning tree to refresh */
-- 
1.6.6.1

