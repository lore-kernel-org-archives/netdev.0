From: Imre Palik <imrep.amz@gmail.com>
Subject: [PATCH] xen-netback: fixing the propagation of the
	transmit shaper timeout
Date: Tue,  6 Jan 2015 16:44:44 +0100
Message-ID: <1420559084-28370-1-git-send-email-imrep.amz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Palik, Imre" <imrep@amazon.de>, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Anthony Liguori <aliguori@amazon.com>, linux-kernel@vger.kernel.org
To: xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xen.org>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

From: "Palik, Imre" <imrep@amazon.de>

Since e9ce7cb6b107 ("xen-netback: Factor queue-specific data into queue struct"),
the transimt shaper timeout is always set to 0.  The value the user sets via
xenbus is never propagated to the transmit shaper.

This patch fixes the issue.

Cc: Anthony Liguori <aliguori@amazon.com>
Signed-off-by: Imre Palik <imrep@amazon.de>
---
 drivers/net/xen-netback/xenbus.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index efbaf2a..794204e 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -737,6 +737,7 @@ static void connect(struct backend_info *be)
 		}
 
 		queue->remaining_credit = credit_bytes;
+		queue->credit_usec = credit_usec;
 
 		err = connect_rings(be, queue);
 		if (err) {
-- 
1.7.9.5
