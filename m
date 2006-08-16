From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH] Restore antenna selection settings after port reset
Date: Tue, 15 Aug 2006 21:41:39 -0400
Message-ID: <20060816014138.6036.74438.stgit@dv.roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Jouni Malinen <jkmaline@cc.hut.fi>, hostap@shmoo.com,
	netdev@vger.kernel.org
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski@gnu.org>

Intersil firmware 1.7.4 (and possibly others) loses the antenna
selection settings when the port is reset.

Signed-off-by: David Acker <dacker@roinet.com>
Signed-off-by: Pavel Roskin <proski@gnu.org>
---

 drivers/net/wireless/hostap/hostap_hw.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index dafaa5f..d500012 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -1042,6 +1042,9 @@ static int prism2_reset_port(struct net_
 		       dev->name, local->fragm_threshold);
 	}
 
+	/* Some firmwares lose antenna selection settings on reset */
+	(void) hostap_set_antsel(local);
+
 	return res;
 }
