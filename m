From: Stephen Hemminger <shemminger@osdl.org>
Subject: __user in atm.h
Date: Tue, 15 Jun 2004 14:42:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615144227.05d2b9fa@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexander Viro <aviro@redhat.com>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Recent Sparse fixes put __user in atm.h 'struct atmif_sioc'
unfortunately, that structure gets used by tools that include atm.h as well
(like iproute2), and in that environment __user is not defined.

Usual fix is to include compiler.h to hide this breakage.

diff -Nru a/include/linux/atm.h b/include/linux/atm.h
--- a/include/linux/atm.h	2004-06-15 14:42:47 -07:00
+++ b/include/linux/atm.h	2004-06-15 14:42:47 -07:00
@@ -20,6 +20,7 @@
 #include <linux/socket.h>
 #include <linux/types.h>
 #endif
+#include <linux/compiler.h>
 #include <linux/atmapi.h>
 #include <linux/atmsap.h>
 #include <linux/atmioc.h>
