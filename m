From: Colin King <colin.king@canonical.com>
Subject: [PATCH] xen/9pfs: use %d format specifier instead of %u for a signed int
Date: Tue, 11 Apr 2017 22:29:38 +0100
Message-ID: <20170411212938.5901-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        "David S . Miller" <davem@davemloft.net>,
        v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

variable i is a signed int, so use the %d print format specifier instead of
%u. Fixes two warnings by cppcheck.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/9p/trans_xen.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/9p/trans_xen.c b/net/9p/trans_xen.c
index 47864245c0d4..9b66087bbc91 100644
--- a/net/9p/trans_xen.c
+++ b/net/9p/trans_xen.c
@@ -441,13 +441,13 @@ static int xen_9pfs_front_probe(struct xenbus_device *dev,
 		char str[16];
 
 		BUILD_BUG_ON(XEN_9PFS_NUM_RINGS > 9);
-		sprintf(str, "ring-ref%u", i);
+		sprintf(str, "ring-ref%d", i);
 		ret = xenbus_printf(xbt, dev->nodename, str, "%d",
 				    priv->rings[i].ref);
 		if (ret)
 			goto error_xenbus;
 
-		sprintf(str, "event-channel-%u", i);
+		sprintf(str, "event-channel-%d", i);
 		ret = xenbus_printf(xbt, dev->nodename, str, "%u",
 				    priv->rings[i].evtchn);
 		if (ret)
-- 
2.11.0
