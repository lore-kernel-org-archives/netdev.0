From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] hostess -- return value check for register_netdev
Date: Fri, 10 Oct 2003 10:32:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031010103225.2177d385.shemminger@osdl.org>
References: <20031009112714.18742308.shemminger@osdl.org>
	<20031010000158.2dc9ce78.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031010000158.2dc9ce78.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Another driver that checks for register_netdev returing -1 when
it can return -EIO or -EEXIST.

diff -Nru a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
--- a/drivers/net/wan/hostess_sv11.c	Fri Oct 10 09:58:31 2003
+++ b/drivers/net/wan/hostess_sv11.c	Fri Oct 10 09:58:31 2003
@@ -337,7 +337,7 @@
 		d->neigh_setup = hostess_neigh_setup_dev;
 		d->set_mac_address = NULL;
 		
-		if(register_netdev(d)==-1)
+		if(register_netdev(d))
 		{
 			printk(KERN_ERR "%s: unable to register device.\n",
 				d->name);
