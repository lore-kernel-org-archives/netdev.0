From: Sven Eckelmann <sven.eckelmann@gmx.de>
Subject: [PATCH] net/9p: Mount only matching virtio channels
Date: Sun, 26 Sep 2010 17:28:13 +0200
Message-ID: <1285514893-11233-1-git-send-email-sven.eckelmann@gmx.de>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sven Eckelmann <sven.eckelmann@gmx.de>
To: ericvh@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

p9_virtio_create will only compare the the channel's tag characters
against the device name till the end of the channel's tag but not till
the end of the device name. This means that if a user defines channels
with the tags foo and foobar then he would mount foo when he requested
foonot and may mount foo when he requested foobar.

Thus it is necessary to check both string lengths against each other in
case of a successful partial string match.

Signed-off-by: Sven Eckelmann <sven.eckelmann@gmx.de>
---
 net/9p/trans_virtio.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index dcfbe99..b885159 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -329,7 +329,8 @@ p9_virtio_create(struct p9_client *client, const char *devname, char *args)
 
 	mutex_lock(&virtio_9p_lock);
 	list_for_each_entry(chan, &virtio_chan_list, chan_list) {
-		if (!strncmp(devname, chan->tag, chan->tag_len)) {
+		if (!strncmp(devname, chan->tag, chan->tag_len) &&
+		    strlen(devname) == chan->tag_len) {
 			if (!chan->inuse) {
 				chan->inuse = true;
 				found = 1;
-- 
1.7.2.3
