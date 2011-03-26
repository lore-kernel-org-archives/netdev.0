From: Mariusz Kozlowski <mk@lab.zgora.pl>
Subject: [PATCH] ceph: fix possible NULL pointer dereference
Date: Sat, 26 Mar 2011 19:29:34 +0100
Message-ID: <1301164174-8597-1-git-send-email-mk@lab.zgora.pl>
Cc: "David S. Miller" <davem@davemloft.net>,
	ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Mariusz Kozlowski <mk@lab.zgora.pl>
To: Sage Weil <sage@newdream.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes 'event_work' dereference before it is checked for NULL.

Signed-off-by: Mariusz Kozlowski <mk@lab.zgora.pl>
---
 net/ceph/osd_client.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
index 02212ed..b6776cb 100644
--- a/net/ceph/osd_client.c
+++ b/net/ceph/osd_client.c
@@ -1602,11 +1602,11 @@ void handle_watch_notify(struct ceph_osd_client *osdc, struct ceph_msg *msg)
 	     cookie, ver, event);
 	if (event) {
 		event_work = kmalloc(sizeof(*event_work), GFP_NOIO);
-		INIT_WORK(&event_work->work, do_event_work);
 		if (!event_work) {
 			dout("ERROR: could not allocate event_work\n");
 			goto done_err;
 		}
+		INIT_WORK(&event_work->work, do_event_work);
 		event_work->event = event;
 		event_work->ver = ver;
 		event_work->notify_id = notify_id;
-- 
1.7.0.4
