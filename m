From: davej@redhat.com
Subject: [PATCH] ipv4 reuses freed mem
Date: Mon, 11 Aug 2003 17:48:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E19mFqr-00068Q-00@tetrachloride>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

cat /proc/net/pnp will return garbage, as the fields it
dumps are initdata.

diff -urpN --exclude-from=/home/davej/.exclude bk-linus/net/ipv4/ipconfig.c linux-2.5/net/ipv4/ipconfig.c
--- bk-linus/net/ipv4/ipconfig.c	2003-07-10 01:02:21.000000000 +0100
+++ linux-2.5/net/ipv4/ipconfig.c	2003-08-09 16:08:13.000000000 +0100
@@ -125,14 +125,14 @@ int ic_proto_enabled __initdata = 0
 
 int ic_host_name_set __initdata = 0;		/* Host name set by us? */
 
-u32 ic_myaddr __initdata = INADDR_NONE;		/* My IP address */
-u32 ic_netmask __initdata = INADDR_NONE;	/* Netmask for local subnet */
-u32 ic_gateway __initdata = INADDR_NONE;	/* Gateway IP address */
+u32 ic_myaddr = INADDR_NONE;		/* My IP address */
+u32 ic_netmask = INADDR_NONE;	/* Netmask for local subnet */
+u32 ic_gateway = INADDR_NONE;	/* Gateway IP address */
 
-u32 ic_servaddr __initdata = INADDR_NONE;	/* Boot server IP address */
+u32 ic_servaddr = INADDR_NONE;	/* Boot server IP address */
 
-u32 root_server_addr __initdata = INADDR_NONE;	/* Address of NFS server */
-u8 root_server_path[256] __initdata = { 0, };	/* Path to mount as root */
+u32 root_server_addr = INADDR_NONE;	/* Address of NFS server */
+u8 root_server_path[256] = { 0, };	/* Path to mount as root */
 
 /* Persistent data: */
 
