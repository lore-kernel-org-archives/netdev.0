From: Vasiliy Kulikov <segooon@gmail.com>
Subject: [PATCH] isdn: mISDN: socket: fix information leak to userland
Date: Sat, 30 Oct 2010 13:04:33 +0400
Message-ID: <1288429473-21864-1-git-send-email-segooon@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Eric Paris <eparis@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Structure mISDN_devinfo is copied to userland with the field "name"
that has the last elements unitialized.  It leads to leaking of
contents of kernel stack memory.

Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
---
 Compile tested.

 drivers/isdn/mISDN/socket.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 3232206..7446d8b 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -392,6 +392,7 @@ data_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		if (dev) {
 			struct mISDN_devinfo di;
 
+			memset(&di, 0, sizeof(di));
 			di.id = dev->id;
 			di.Dprotocols = dev->Dprotocols;
 			di.Bprotocols = dev->Bprotocols | get_all_Bprotocols();
@@ -672,6 +673,7 @@ base_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		if (dev) {
 			struct mISDN_devinfo di;
 
+			memset(&di, 0, sizeof(di));
 			di.id = dev->id;
 			di.Dprotocols = dev->Dprotocols;
 			di.Bprotocols = dev->Bprotocols | get_all_Bprotocols();
-- 
1.7.0.4
