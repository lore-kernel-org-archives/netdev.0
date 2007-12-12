From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] XFRM: Display the audited SPI value in host byte order
Date: Wed, 12 Dec 2007 14:05:42 -0500
Message-ID: <20071212190542.20699.96051.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-audit@redhat.com
To: netdev@vger.kernel.org
Return-path: <linux-audit-bounces@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Currently the IPsec protocol SPI values are written to the audit log in
network byte order which is different from almost all other values which
are recorded in host byte order.  This patch corrects this inconsistency
by writing the SPI values to the audit record in host byte order.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 net/xfrm/xfrm_state.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index cf43c49..1af522b 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2028,6 +2028,7 @@ void
 xfrm_audit_state_add(struct xfrm_state *x, int result, u32 auid, u32 sid)
 {
 	struct audit_buffer *audit_buf;
+	u32 spi;
 	extern int audit_enabled;
 
 	if (audit_enabled == 0)
@@ -2037,8 +2038,8 @@ xfrm_audit_state_add(struct xfrm_state *x, int result, u32 auid, u32 sid)
 		return;
 	audit_log_format(audit_buf, " op=SAD-add res=%u",result);
 	xfrm_audit_common_stateinfo(x, audit_buf);
-	audit_log_format(audit_buf, " spi=%lu(0x%lx)",
-			 (unsigned long)x->id.spi, (unsigned long)x->id.spi);
+	spi = ntohl(x->id.spi);
+	audit_log_format(audit_buf, " spi=%u(0x%x)", spi, spi);
 	audit_log_end(audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_add);
@@ -2047,6 +2048,7 @@ void
 xfrm_audit_state_delete(struct xfrm_state *x, int result, u32 auid, u32 sid)
 {
 	struct audit_buffer *audit_buf;
+	u32 spi;
 	extern int audit_enabled;
 
 	if (audit_enabled == 0)
@@ -2056,8 +2058,8 @@ xfrm_audit_state_delete(struct xfrm_state *x, int result, u32 auid, u32 sid)
 		return;
 	audit_log_format(audit_buf, " op=SAD-delete res=%u",result);
 	xfrm_audit_common_stateinfo(x, audit_buf);
-	audit_log_format(audit_buf, " spi=%lu(0x%lx)",
-			 (unsigned long)x->id.spi, (unsigned long)x->id.spi);
+	spi = ntohl(x->id.spi);
+	audit_log_format(audit_buf, " spi=%u(0x%x)", spi, spi);
 	audit_log_end(audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_delete);
