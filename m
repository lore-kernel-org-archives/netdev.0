From: John Jolly <jjolly@suse.com>
Subject: [PATCH] rds: Error on offset mismatch if not loopback
Date: Fri, 21 Sep 2012 15:32:40 -0600
Message-ID: <20120921213239.GJ14393@linux-tkdk.sfcn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: venkat.x.venkatsubra@oracle.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Attempting an rds connection from the IP address of an IPoIB interface
to itself causes a kernel panic due to a BUG_ON() being triggered.
Making the test less strict allows rds-ping to work without crashing
the machine.

A local unprivileged user could use this flaw to crash the system.

Signed-off-by: John Jolly <jjolly@suse.com>
---
 net/rds/ib_send.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index e590949..7920c85 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -544,7 +544,7 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
        int flow_controlled = 0;
        int nr_sig = 0;
 
-       BUG_ON(off % RDS_FRAG_SIZE);
+       BUG_ON(!conn->c_loopback && off % RDS_FRAG_SIZE);
        BUG_ON(hdr_off != 0 && hdr_off != sizeof(struct rds_header));
 
        /* Do not send cong updates to IB loopback */
-- 
1.7.7
