From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 12/18] virtio_test: support used_event index
Date: Wed, 4 May 2011 23:52:14 +0300
Message-ID: <3f1f65fa3724ae084109fd77aa1d92d7ef1c328a.1304541919.git.mst@redhat.com>
References: <cover.1304541918.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, Carsten Otte <cotte@de.ibm.com>,
        lguest@lists.ozlabs.org, Shirley Ma <xma@us.ibm.com>,
        kvm@vger.kernel.org, linux-s390@vger.kernel.org,
        netdev@vger.kernel.org, habanero@linux.vnet.ibm.com,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org, steved@us.ibm.com,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Tom Lendacky <tahm@linux.vnet.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>, linux390@de.ibm.com
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cover.1304541918.git.mst@redhat.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Add ability to test the new used_event feature,
enable by default.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 tools/virtio/virtio_test.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/tools/virtio/virtio_test.c b/tools/virtio/virtio_test.c
index 9e65e6d..157ec68 100644
--- a/tools/virtio/virtio_test.c
+++ b/tools/virtio/virtio_test.c
@@ -210,18 +210,29 @@ const struct option longopts[] = {
 		.val = 'i',
 	},
 	{
+		.name = "used-event-idx",
+		.val = 'U',
+	},
+	{
+		.name = "no-used-event-idx",
+		.val = 'u',
+	},
+	{
 	}
 };
 
 static void help()
 {
-	fprintf(stderr, "Usage: virtio_test [--help] [--no-indirect]\n");
+	fprintf(stderr, "Usage: virtio_test [--help]"
+		" [--no-indirect] "
+		" [--no-used-event-idx]\n");
 }
 
 int main(int argc, char **argv)
 {
 	struct vdev_info dev;
-	unsigned long long features = 1ULL << VIRTIO_RING_F_INDIRECT_DESC;
+	unsigned long long features = (1ULL << VIRTIO_RING_F_INDIRECT_DESC) |
+		(1ULL << VIRTIO_RING_F_USED_EVENT_IDX);
 	int o;
 
 	for (;;) {
@@ -238,6 +249,9 @@ int main(int argc, char **argv)
 		case 'i':
 			features &= ~(1ULL << VIRTIO_RING_F_INDIRECT_DESC);
 			break;
+		case 'u':
+			features &= ~(1ULL << VIRTIO_RING_F_USED_EVENT_IDX);
+			break;
 		default:
 			assert(0);
 			break;
-- 
1.7.5.53.gc233e
