From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 and 2.4.26 finally working
Date: Sat, 15 May 2004 01:27:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040515012714.A9616@electric-eye.fr.zoreil.com>
References: <000001c439ca$b0c39040$4500a8c0@freelancer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: a.nielsen@optushome.com.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Johannes Petersson <johpe@vimmerbytidning.se>
Content-Disposition: inline
In-Reply-To: <000001c439ca$b0c39040$4500a8c0@freelancer>; from johpe@vimmerbytidning.se on Fri, May 14, 2004 at 05:46:57PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Johannes Petersson <johpe@vimmerbytidning.se> :
[...]
> The patches were tried one at a time to the vanilla sources for the 
> 2.4.26 kernel. The 2.4.26-r8169.c-stable.patch gave the usual error
> about not beeing able to patch the file completely when I applied it to
> the kernel source.
[...]
> The only patched that actually applied without any problems to the 
> kernel was the 20040504-2.4.27-pre1-r8169.c-test.patch from Francois. At
> 
> that time I had some hope. But while compiling the kernel with the 
> 2.4.27-pre1-r8169 patch I got the following compile errors when I issued
> "make bzImage":
> Implicit declaration of netdev_priv

This function requires at least a 2.4.27-pre1 kernel.

Please try a 2.4.27-pre1 kernel or apply the following patch to your
2.4.26 tree before/after 20040504-2.4.27-pre1-r8169.c-test.patch


diff -Nur --show-c-function linux-2.4.26/include/linux/netdevice.h linux-2.4.27-pre1/include/linux/netdevice.h
--- linux-2.4.26/include/linux/netdevice.h	2004-02-18 10:36:32.000000000 -0300
+++ linux-2.4.27-pre1/include/linux/netdevice.h	2004-04-21 19:59:15.000000000 -0300
@@ -467,6 +468,10 @@ struct packet_type 
 	struct packet_type	*next;
 };
 
+static inline void *netdev_priv(struct net_device *dev)
+{
+	return dev->priv;
+}
 
 #include <linux/interrupt.h>
 #include <linux/notifier.h>
