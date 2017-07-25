From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH] netpoll: Fix device name check in netpoll_setup()
Date: Tue, 25 Jul 2017 11:36:25 -0700
Message-ID: <20170725183625.132345-1-mka@chromium.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Doug Anderson <dianders@chromium.org>,
        Matthias Kaehlcke <mka@chromium.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Apparently netpoll_setup() assumes that netpoll.dev_name is a pointer
when checking if the device name is set:

if (np->dev_name) {
  ...

However the field is a character array, therefore the condition always
yields true. Check instead whether the first byte of the array has a
non-zero value.

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 net/core/netpoll.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 8357f164c660..912731bed7b7 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -666,7 +666,7 @@ int netpoll_setup(struct netpoll *np)
 	int err;
 
 	rtnl_lock();
-	if (np->dev_name) {
+	if (np->dev_name[0]) {
 		struct net *net = current->nsproxy->net_ns;
 		ndev = __dev_get_by_name(net, np->dev_name);
 	}
-- 
2.14.0.rc0.284.gd933b75aa4-goog
