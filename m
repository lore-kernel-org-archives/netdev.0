From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: bluetooth: remove unneeded verify_area call
Date: Thu, 25 Sep 2003 21:56:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925215637.42631e42.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.0-test5-current.

Thanks,
--
~Randy


From: Domen Puncer <domen@coderock.org>

 linux-260-t5bk12-kj-rddunlap/net/bluetooth/hci_core.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff -puN net/bluetooth/hci_core.c~net_bluetooth_hcicore_verify net/bluetooth/hci_core.c
--- linux-260-t5bk12-kj/net/bluetooth/hci_core.c~net_bluetooth_hcicore_verify	2003-09-25 16:01:20.000000000 -0700
+++ linux-260-t5bk12-kj-rddunlap/net/bluetooth/hci_core.c	2003-09-25 16:01:20.000000000 -0700
@@ -434,11 +434,11 @@ int hci_inquiry(unsigned long arg)
 
 	BT_DBG("num_rsp %d", ir.num_rsp);
 
-	if (!verify_area(VERIFY_WRITE, ptr, sizeof(ir) + 
-			(sizeof(struct inquiry_info) * ir.num_rsp))) {
-		copy_to_user(ptr, &ir, sizeof(ir));
+	if (!copy_to_user(ptr, &ir, sizeof(ir))) {
 		ptr += sizeof(ir);
-	        copy_to_user(ptr, buf, sizeof(struct inquiry_info) * ir.num_rsp);
+	        if (copy_to_user(ptr, buf, sizeof(struct inquiry_info) *
+					ir.num_rsp))
+			err = -EFAULT;
 	} else 
 		err = -EFAULT;
 

_
