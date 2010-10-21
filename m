From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC][net-next-2.6 PATCH 4/4] net: remove check for headroom in
	vlan_dev_create
Date: Thu, 21 Oct 2010 15:10:20 -0700
Message-ID: <20101021221020.22906.96059.stgit@jf-dev1-dcblab>
References: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2589 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751942Ab0JUWLn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 18:11:43 -0400
In-Reply-To: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible for the headroom to be smaller then the
hard_header_len for a short period of time after toggling
the vlan offload setting.

This is not a hard error and skb_cow_head is called in
__vlan_put_tag() to resolve this.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/8021q/vlan_dev.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1645c3c..e043389 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -238,9 +238,6 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 {
 	int rc;
 
-	if (WARN_ON(skb_headroom(skb) < dev->hard_header_len))
-		return -ENOSPC;
-
 	/* When this flag is not set we make the vlan_tci visible
 	 * by setting the skb field.
 	 *

