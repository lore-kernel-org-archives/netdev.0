From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATH] atm/clip device discovery on init not needed
Date: Wed, 14 Jan 2004 16:43:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040114164338.1f0d15e4.shemminger@osdl.org>
References: <20040113105843.0d1351cb.shemminger@osdl.org>
	<20040113163631.1a9c1a59.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, chas williams <chas@cmf.nrl.navy.mil>,
        linux-atm-general@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040113163631.1a9c1a59.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Atm/clip driver was doing device list walk to find interfaces.
This will no longer be needed now that events are replayed when
register_netdevice_notifier is called (see earlier patch)

diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Wed Jan 14 16:27:05 2004
+++ b/net/atm/clip.c	Wed Jan 14 16:27:05 2004
@@ -754,9 +754,6 @@
 		printk(KERN_ERR "register_netdevice_notifier failed\n");
 	if (register_inetaddr_notifier(&clip_inet_notifier))
 		printk(KERN_ERR "register_inetaddr_notifier failed\n");
-	for (dev = clip_devs; dev; dev = PRIV(dev)->next)
-		if (dev->flags & IFF_UP)
-			(void) to_atmarpd(act_up,PRIV(dev)->number,0);
 	return 0;
 }
 
