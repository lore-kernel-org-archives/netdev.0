From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC 2/6] Add dgram_skb to vsock_sock
Date: Wed, 27 May 2015 18:05:56 +0100
Message-ID: <1432746360-14940-3-git-send-email-stefanha@redhat.com>
References: <1432746360-14940-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Asias He <asias@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: kvm@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1432746360-14940-1-git-send-email-stefanha@redhat.com>
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

From: Asias He <asias@redhat.com>

This list will be used to match received packets when multiple packets
are used because datagram size is larger than the receive buffer size.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/net/af_vsock.h   | 1 +
 net/vmw_vsock/af_vsock.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index d52b984..bc9055c 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -58,6 +58,7 @@ struct vsock_sock {
 	 */
 	struct list_head pending_links;
 	struct list_head accept_queue;
+	struct list_head dgram_skb;
 	bool rejected;
 	struct delayed_work dwork;
 	u32 peer_shutdown;
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index ae3ce3d..0b3c498 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -684,6 +684,7 @@ struct sock *__vsock_create(struct net *net,
 	vsk->listener = NULL;
 	INIT_LIST_HEAD(&vsk->pending_links);
 	INIT_LIST_HEAD(&vsk->accept_queue);
+	INIT_LIST_HEAD(&vsk->dgram_skb); /* TODO free list entries on shutdown and limit list size or timeout somehow? */
 	vsk->rejected = false;
 	vsk->sent_request = false;
 	vsk->ignore_connecting_rst = false;
-- 
2.4.1
