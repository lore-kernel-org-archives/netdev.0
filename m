From: jamal <hadi@cyberus.ca>
Subject: Re: 2.6: QoS scheduling not working with IP-over-IP
Date: 12 Feb 2004 00:04:42 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076562282.1033.76.camel@jzny.localdomain>
References: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>
	 <20040211200549.736fa8b3.davem@redhat.com>
	 <1076561489.1032.65.camel@jzny.localdomain>
	 <1076561998.1035.72.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-x9OUX6bGj+32eMtlf6bv"
Cc: Dawid Kuroczko <qnex@atlantis.knm.org.pl>, netdev@oss.sgi.com,
        shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <1076561998.1035.72.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-x9OUX6bGj+32eMtlf6bv
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2004-02-11 at 23:59, jamal wrote:
> What the heck, heres a patch (maybe it ll teach that poster to post to
> netdev instead of lk ;->). Not tested not even compiled but looks fine.
> ipip was always broken; the pfifo off by one fix in 2.6 seems to have
> exposed the bug.
> 

More complete patch attached for other broken tunnel devices.
Note the bug exists in 2.4 as well but is masquareded by a boundary bug
in pfifo.

cheers,
jamal


--=-x9OUX6bGj+32eMtlf6bv
Content-Disposition: attachment; filename=p1
Content-Type: text/plain; name=p1; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- 261/net/ipv4/ip_gre.c	2004-01-09 01:59:48.000000000 -0500
+++ 261-mod/net/ipv4/ip_gre.c	2004-02-11 23:57:30.000000000 -0500
@@ -276,6 +276,7 @@
 	  return NULL;
 
 	dev->init = ipgre_tunnel_init;
+	dev->tx_queue_len = 100;
 	nt = dev->priv;
 	nt->parms = *parms;
 
--- 261/net/ipv4/ipip.c	2004-01-09 02:00:13.000000000 -0500
+++ 261-mod/net/ipv4/ipip.c	2004-02-11 23:35:18.000000000 -0500
@@ -247,6 +247,7 @@
 	SET_MODULE_OWNER(dev);
 	dev->init = ipip_tunnel_init;
 	dev->destructor = free_netdev;
+	dev->tx_queue_len = 100;
 	nt->parms = *parms;
 
 	if (register_netdevice(dev) < 0) {
--- 261/net/ipv6/sit.c	2004-01-09 02:00:03.000000000 -0500
+++ 261-mod/net/ipv6/sit.c	2004-02-11 23:58:00.000000000 -0500
@@ -184,6 +184,7 @@
 
 	nt = dev->priv;
 	dev->init = ipip6_tunnel_init;
+	dev->tx_queue_len = 100;
 	nt->parms = *parms;
 
 	if (register_netdevice(dev) < 0) {

--=-x9OUX6bGj+32eMtlf6bv--
