From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] ipv4: remove 0/NULL assignment on static
Date: Tue,  4 Nov 2014 20:37:46 +0100
Message-ID: <1415129866-13852-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

static values are automatically initialized to 0

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/ipconfig.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index a896da5..7fa18bc 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -115,7 +115,7 @@
  */
 int ic_set_manually __initdata = 0;		/* IPconfig parameters set manually */
 
-static int ic_enable __initdata = 0;		/* IP config enabled? */
+static int ic_enable __initdata;		/* IP config enabled? */
 
 /* Protocol choice */
 int ic_proto_enabled __initdata = 0
@@ -130,7 +130,7 @@ int ic_proto_enabled __initdata = 0
 #endif
 			;
 
-static int ic_host_name_set __initdata = 0;	/* Host name set by us? */
+static int ic_host_name_set __initdata;	/* Host name set by us? */
 
 __be32 ic_myaddr = NONE;		/* My IP address */
 static __be32 ic_netmask = NONE;	/* Netmask for local subnet */
@@ -160,17 +160,17 @@ static u8 ic_domain[64];		/* DNS (not NIS) domain name */
 static char user_dev_name[IFNAMSIZ] __initdata = { 0, };
 
 /* Protocols supported by available interfaces */
-static int ic_proto_have_if __initdata = 0;
+static int ic_proto_have_if __initdata;
 
 /* MTU for boot device */
-static int ic_dev_mtu __initdata = 0;
+static int ic_dev_mtu __initdata;
 
 #ifdef IPCONFIG_DYNAMIC
 static DEFINE_SPINLOCK(ic_recv_lock);
-static volatile int ic_got_reply __initdata = 0;    /* Proto(s) that replied */
+static volatile int ic_got_reply __initdata;    /* Proto(s) that replied */
 #endif
 #ifdef IPCONFIG_DHCP
-static int ic_dhcp_msgtype __initdata = 0;	/* DHCP msg type received */
+static int ic_dhcp_msgtype __initdata;	/* DHCP msg type received */
 #endif
 
 
@@ -186,8 +186,8 @@ struct ic_device {
 	__be32 xid;
 };
 
-static struct ic_device *ic_first_dev __initdata = NULL;/* List of open device */
-static struct net_device *ic_dev __initdata = NULL;	/* Selected device */
+static struct ic_device *ic_first_dev __initdata;	/* List of open device */
+static struct net_device *ic_dev __initdata;		/* Selected device */
 
 static bool __init ic_is_init_dev(struct net_device *dev)
 {
-- 
1.9.3
