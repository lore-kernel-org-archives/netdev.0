From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6: QoS scheduling not working with IP-over-IP
Date: Wed, 11 Feb 2004 22:22:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211222259.776ad818.davem@redhat.com>
References: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>
	<20040211200549.736fa8b3.davem@redhat.com>
	<1076561489.1032.65.camel@jzny.localdomain>
	<1076561998.1035.72.camel@jzny.localdomain>
	<1076562282.1033.76.camel@jzny.localdomain>
	<20040211211536.23e97997.davem@redhat.com>
	<1076563502.1031.85.camel@jzny.localdomain>
	<1076564638.1033.91.camel@jzny.localdomain>
	<20040211215142.7f817513.davem@redhat.com>
	<1076566176.1033.94.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: qnex@atlantis.knm.org.pl, netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1076566176.1033.94.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 12 Feb 2004 01:09:36 -0500
jamal <hadi@cyberus.ca> wrote:

> On Thu, 2004-02-12 at 00:51, David S. Miller wrote:
> 
> >  Show me a code path where more than one packet
> > can occupy the queue of one of these tunnel devices? :-)
> 
> ok, makes sense ;->

Great, here is the patch I am testing now.

BTW, you missed fixing up the xxx0 device in each of these things.

===== net/ipv4/ip_gre.c 1.34 vs edited =====
--- 1.34/net/ipv4/ip_gre.c	Tue Oct 28 01:13:14 2003
+++ edited/net/ipv4/ip_gre.c	Wed Feb 11 22:17:28 2004
@@ -276,6 +276,7 @@
 	  return NULL;
 
 	dev->init = ipgre_tunnel_init;
+	dev->tx_queue_len = 1;
 	nt = dev->priv;
 	nt->parms = *parms;
 
@@ -1269,6 +1270,7 @@
 	}
 
 	ipgre_fb_tunnel_dev->init = ipgre_fb_tunnel_init;
+	ipgre_fb_tunnel_dev->tx_queue_len = 1;
 
 	if ((err = register_netdev(ipgre_fb_tunnel_dev)))
 		goto fail;
===== net/ipv4/ipip.c 1.37 vs edited =====
--- 1.37/net/ipv4/ipip.c	Sun Oct 19 00:12:04 2003
+++ edited/net/ipv4/ipip.c	Wed Feb 11 22:17:46 2004
@@ -246,6 +246,7 @@
 	nt = dev->priv;
 	SET_MODULE_OWNER(dev);
 	dev->init = ipip_tunnel_init;
+	dev->tx_queue_len = 1;
 	dev->destructor = free_netdev;
 	nt->parms = *parms;
 
@@ -892,6 +893,7 @@
 	}
 
 	ipip_fb_tunnel_dev->init = ipip_fb_tunnel_init;
+	ipip_fb_tunnel_dev->tx_queue_len = 1;
 
 	if ((err = register_netdev(ipip_fb_tunnel_dev)))
 	    goto fail;
===== net/ipv6/sit.c 1.33 vs edited =====
--- 1.33/net/ipv6/sit.c	Mon Jan 19 21:23:19 2004
+++ edited/net/ipv6/sit.c	Wed Feb 11 22:18:05 2004
@@ -184,6 +184,7 @@
 
 	nt = dev->priv;
 	dev->init = ipip6_tunnel_init;
+	dev->tx_queue_len = 1;
 	nt->parms = *parms;
 
 	if (register_netdevice(dev) < 0) {
@@ -832,6 +833,7 @@
 	}
 
 	ipip6_fb_tunnel_dev->init = ipip6_fb_tunnel_init;
+	ipip6_fb_tunnel_dev->tx_queue_len = 1;
 
 	if ((err =  register_netdev(ipip6_fb_tunnel_dev)))
 		goto fail;
