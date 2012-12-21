From: Mike Marciniszyn <mike.marciniszyn@intel.com>
Subject: [PATCH 2/2] IB/rds: suppress incompatible protocol when version is
	known
Date: Fri, 21 Dec 2012 13:01:54 -0500
Message-ID: <20121221180154.23716.44540.stgit@phlsvslse11.ph.intel.com>
References: <20121221175857.23716.46975.stgit@phlsvslse11.ph.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, roland@kernel.org,
	rds-devel@oss.oracle.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: venkat.x.venkatsubra@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28659 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751830Ab2LUSB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2012 13:01:57 -0500
In-Reply-To: <20121221175857.23716.46975.stgit@phlsvslse11.ph.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an else to only print the incompatible protocol message
when version hasn't been established.

Signed-off-by: Mike Marciniszyn <mike.marciniszyn@intel.com>
---
 net/rds/ib_cm.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index a1e1162..31b74f5 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -434,12 +434,11 @@ static u32 rds_ib_protocol_compatible(struct rdma_cm_event *event)
 		version = RDS_PROTOCOL_3_0;
 		while ((common >>= 1) != 0)
 			version++;
-	}
-	printk_ratelimited(KERN_NOTICE "RDS: Connection from %pI4 using "
-			"incompatible protocol version %u.%u\n",
-			&dp->dp_saddr,
-			dp->dp_protocol_major,
-			dp->dp_protocol_minor);
+	} else
+		printk_ratelimited(KERN_NOTICE "RDS: Connection from %pI4 using incompatible protocol version %u.%u\n",
+				&dp->dp_saddr,
+				dp->dp_protocol_major,
+				dp->dp_protocol_minor);
 	return version;
 }
 
