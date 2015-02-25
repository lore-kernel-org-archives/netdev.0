From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost: drop hard-coded num_buffers size
Date: Wed, 25 Feb 2015 15:20:01 +0100
Message-ID: <1424873997-16686-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

The 2 that we use for copy_to_iter comes from sizeof(u16),
it used to be that way before the iov iter update.
Fix it up, making it obvious the size of stack access
is right.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index ca70434..2bbfc25 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -621,7 +621,8 @@ static void handle_rx(struct vhost_net *net)
 
 		num_buffers = cpu_to_vhost16(vq, headcount);
 		if (likely(mergeable) &&
-		    copy_to_iter(&num_buffers, 2, &fixup) != 2) {
+		    copy_to_iter(&num_buffers, sizeof num_buffers,
+				 &fixup) != sizeof num_buffers) {
 			vq_err(vq, "Failed num_buffers write");
 			vhost_discard_vq_desc(vq, headcount);
 			break;
-- 
MST
