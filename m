From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] vhost-net: fix range checking in mrg bufs case
Date: Tue, 14 Sep 2010 15:15:52 +0200
Message-ID: <20100914131552.GA1937@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In mergeable buffer case, we use headcount, log_num
and seg as indexes in same-size arrays, and
we know that headcount <= seg and
log_num equals either 0 or seg.

Therefore, the right thing to do is range-check seg,
not headcount as we do now: these will be different
if guest chains s/g descriptors (this does not
happen now, but we can not trust the guest).

Long term, we should add BUG_ON checks to verify
two other indexes are what we think they should be.

Reported-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Dave, I'll queue this on my tree, no need to bother.

 drivers/vhost/net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 6400cd5..f095de6 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -245,7 +245,7 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
 	int r, nlogs = 0;
 
 	while (datalen > 0) {
-		if (unlikely(headcount >= VHOST_NET_MAX_SG)) {
+		if (unlikely(seg >= VHOST_NET_MAX_SG)) {
 			r = -ENOBUFS;
 			goto err;
 		}
-- 
1.7.3.rc1.5.ge5969
