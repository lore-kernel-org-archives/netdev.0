From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tun -- name fix
Date: Mon, 15 Mar 2004 10:22:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040315102215.65c26745@dell_ss3.pdx.osdl.net>
References: <20040313164325.070524df.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Gerd Knorr <kraxel@bytesex.org>, rutger@mail.com, netdev@oss.sgi.com,
        Maxim Krasnyansky <maxk@qualcomm.com>, vtun@office.satix.net.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040313164325.070524df.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This fixes both the devfs name and the /sys name issues.
It ends up as /dev/net/tun and /sys/class/misc/tun looks correct.


diff -Nru a/drivers/net/tun.c b/drivers/net/tun.c
--- a/drivers/net/tun.c	Mon Mar 15 10:01:52 2004
+++ b/drivers/net/tun.c	Mon Mar 15 10:01:52 2004
@@ -602,8 +602,9 @@
 
 static struct miscdevice tun_miscdev = {
 	.minor = TUN_MINOR,
-	.name = "net/tun",
-	.fops = &tun_fops
+	.name = "tun",
+	.fops = &tun_fops,
+	.devfs_name = "net/tun",
 };
 
 int __init tun_init(void)
