From: Peng Tao <bergwolf@gmail.com>
Subject: [PATCH] vhost-vsock: fix orphan connection reset
Date: Wed,  7 Dec 2016 17:45:47 +0800
Message-ID: <1481103947-76771-1-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org#4.8+,
	Peng Tao <bergwolf@gmail.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

local_addr.svm_cid is host cid. We should check guest cid instead,
which is remote_addr.svm_cid.

Cc: Stefan Hajnoczi <stefanha@redhat.com>
Cc: stable@vger.kernel.org #4.8+
Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 drivers/vhost/vsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index e3b30ea..a504e2e0 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -506,7 +506,7 @@ static void vhost_vsock_reset_orphans(struct sock *sk)
 	 * executing.
 	 */
 
-	if (!vhost_vsock_get(vsk->local_addr.svm_cid)) {
+	if (!vhost_vsock_get(vsk->remote_addr.svm_cid)) {
 		sock_set_flag(sk, SOCK_DONE);
 		vsk->peer_shutdown = SHUTDOWN_MASK;
 		sk->sk_state = SS_UNCONNECTED;
-- 
2.7.4
