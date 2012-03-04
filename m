From: Paul Mackerras <paulus@samba.org>
Subject: [PATCH 3/3] ppp: Replace uses of <linux/if_ppp.h> with
 <linux/ppp-ioctl.h>
Date: Mon, 5 Mar 2012 09:56:55 +1100
Message-ID: <20120304225655.GD10646@bloggs.ozlabs.ibm.com>
References: <20120304225336.GA10646@bloggs.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kiszka <jan.kiszka@siemens.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120304225336.GA10646@bloggs.ozlabs.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since all that include/linux/if_ppp.h does is #include <linux/ppp-ioctl.h>,
this replaces the occurrences of #include <linux/if_ppp.h> with
#include <linux/ppp-ioctl.h>.

It also corrects an error in Documentation/networking/l2tp.txt, where
it referenced include/linux/if_ppp.h as the source of some definitions
that are actually now defined in include/linux/if_pppol2tp.h.

Signed-off-by: Paul Mackerras <paulus@samba.org>
---
 Documentation/networking/l2tp.txt |    2 +-
 drivers/isdn/capi/capi.c          |    2 +-
 drivers/net/ppp/ppp_async.c       |    2 +-
 drivers/net/ppp/ppp_synctty.c     |    2 +-
 drivers/net/ppp/pppoe.c           |    2 +-
 drivers/net/ppp/pppox.c           |    2 +-
 drivers/tty/ipwireless/network.c  |    2 +-
 drivers/tty/ipwireless/tty.c      |    2 +-
 fs/compat_ioctl.c                 |    2 +-
 include/linux/isdn.h              |    2 +-
 net/atm/pppoatm.c                 |    2 +-
 net/irda/irnet/irnet.h            |    2 +-
 net/l2tp/l2tp_ppp.c               |    2 +-
 13 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/l2tp.txt b/Documentation/networking/l2tp.txt
index e7bf397..e63fc1f 100644
--- a/Documentation/networking/l2tp.txt
+++ b/Documentation/networking/l2tp.txt
@@ -111,7 +111,7 @@ When creating PPPoL2TP sockets, the application provides information
 to the driver about the socket in a socket connect() call. Source and
 destination tunnel and session ids are provided, as well as the file
 descriptor of a UDP socket. See struct pppol2tp_addr in
-include/linux/if_ppp.h. Note that zero tunnel / session ids are
+include/linux/if_pppol2tp.h. Note that zero tunnel / session ids are
 treated specially. When creating the per-tunnel PPPoL2TP management
 socket in Step 2 above, zero source and destination session ids are
 specified, which tells the driver to prepare the supplied UDP file
diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index e44933d..e3dfbed 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -25,7 +25,7 @@
 #include <linux/tty.h>
 #include <linux/netdevice.h>
 #include <linux/ppp_defs.h>
-#include <linux/if_ppp.h>
+#include <linux/ppp-ioctl.h>
 #include <linux/skbuff.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
diff --git a/drivers/net/ppp/ppp_async.c b/drivers/net/ppp/ppp_async.c
index c6ba643..af95a98 100644
--- a/drivers/net/ppp/ppp_async.c
+++ b/drivers/net/ppp/ppp_async.c
@@ -26,7 +26,7 @@
 #include <linux/poll.h>
 #include <linux/crc-ccitt.h>
 #include <linux/ppp_defs.h>
-#include <linux/if_ppp.h>
+#include <linux/ppp-ioctl.h>
 #include <linux/ppp_channel.h>
 #include <linux/spinlock.h>
 #include <linux/init.h>
diff --git a/drivers/net/ppp/ppp_synctty.c b/drivers/net/ppp/ppp_synctty.c
index 736a39e..55e466c 100644
--- a/drivers/net/ppp/ppp_synctty.c
+++ b/drivers/net/ppp/ppp_synctty.c
@@ -39,7 +39,7 @@
 #include <linux/netdevice.h>
 #include <linux/poll.h>
 #include <linux/ppp_defs.h>
-#include <linux/if_ppp.h>
+#include <linux/ppp-ioctl.h>
 #include <linux/ppp_channel.h>
 #include <linux/spinlock.h>
 #include <linux/completion.h>
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index bc9a4bb..2fa1a9b 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -72,7 +72,7 @@
 #include <linux/if_pppox.h>
 #include <linux/ppp_channel.h>
 #include <linux/ppp_defs.h>
-#include <linux/if_ppp.h>
+#include <linux/ppp-ioctl.h>
 #include <linux/notifier.h>
 #include <linux/file.h>
 #include <linux/proc_fs.h>
diff --git a/drivers/net/ppp/pppox.c b/drivers/net/ppp/pppox.c
index 8c0d170d..2940e9f 100644
--- a/drivers/net/ppp/pppox.c
+++ b/drivers/net/ppp/pppox.c
@@ -28,7 +28,7 @@
 #include <linux/init.h>
 #include <linux/if_pppox.h>
 #include <linux/ppp_defs.h>
-#include <linux/if_ppp.h>
+#include <linux/ppp-ioctl.h>
 #include <linux/ppp_channel.h>
 #include <linux/kmod.h>
 
diff --git a/drivers/tty/ipwireless/network.c b/drivers/tty/ipwireless/network.c
index f7daeea..57c8b48 100644
--- a/drivers/tty/ipwireless/network.c
+++ b/drivers/tty/ipwireless/network.c
@@ -22,7 +22,7 @@
 #include <linux/ppp_channel.h>
 #include <linux/ppp_defs.h>
 #include <linux/slab.h>
-#include <linux/if_ppp.h>
+#include <linux/ppp-ioctl.h>
 #include <linux/skbuff.h>
 
 #include "network.h"
diff --git a/drivers/tty/ipwireless/tty.c b/drivers/tty/ipwireless/tty.c
index ef92869..2ffa0b7 100644
--- a/drivers/tty/ipwireless/tty.c
+++ b/drivers/tty/ipwireless/tty.c
@@ -21,7 +21,7 @@
 #include <linux/mutex.h>
 #include <linux/ppp_defs.h>
 #include <linux/if.h>
-#include <linux/if_ppp.h>
+#include <linux/ppp-ioctl.h>
 #include <linux/sched.h>
 #include <linux/serial.h>
 #include <linux/slab.h>
diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index a26bea1..10d8cd9 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -34,7 +34,7 @@
 #include <linux/fs.h>
 #include <linux/file.h>
 #include <linux/ppp_defs.h>
-#include <linux/if_ppp.h>
+#include <linux/ppp-ioctl.h>
 #include <linux/if_pppox.h>
 #include <linux/mtio.h>
 #include <linux/auto_fs.h>
diff --git a/include/linux/isdn.h b/include/linux/isdn.h
index 4ccf95d..292f27a 100644
--- a/include/linux/isdn.h
+++ b/include/linux/isdn.h
@@ -187,7 +187,7 @@ typedef struct {
 #endif
 
 #include <linux/ppp_defs.h>
-#include <linux/if_ppp.h>
+#include <linux/ppp-ioctl.h>
 
 #include <linux/isdn_ppp.h>
 #endif
diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index df35d9a..614d3fc 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -44,7 +44,7 @@
 #include <linux/atmdev.h>
 #include <linux/capability.h>
 #include <linux/ppp_defs.h>
-#include <linux/if_ppp.h>
+#include <linux/ppp-ioctl.h>
 #include <linux/ppp_channel.h>
 #include <linux/atmppp.h>
 
diff --git a/net/irda/irnet/irnet.h b/net/irda/irnet/irnet.h
index 979ecb2..564eb0b 100644
--- a/net/irda/irnet/irnet.h
+++ b/net/irda/irnet/irnet.h
@@ -254,7 +254,7 @@
 #include <linux/init.h>
 
 #include <linux/ppp_defs.h>
-#include <linux/if_ppp.h>
+#include <linux/ppp-ioctl.h>
 #include <linux/ppp_channel.h>
 
 #include <net/irda/irda.h>
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 8a90d75..96bc7a6 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -82,7 +82,7 @@
 #include <net/sock.h>
 #include <linux/ppp_channel.h>
 #include <linux/ppp_defs.h>
-#include <linux/if_ppp.h>
+#include <linux/ppp-ioctl.h>
 #include <linux/file.h>
 #include <linux/hash.h>
 #include <linux/sort.h>
-- 
1.7.9.1
