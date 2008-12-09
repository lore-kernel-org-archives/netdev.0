From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] simnet: convert to net_device_ops
Date: Tue, 9 Dec 2008 18:08:27 +0300
Message-ID: <20081209150827.GA8134@x200.localdomain>
References: <a4423d670812090611v715309adq3e9d2d95254e2e16@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	linux-ia64@vger.kernel.org
To: Alexander Beregalov <a.beregalov@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:35590 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbYLIPED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 10:04:03 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1114030ugf.37
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 07:04:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <a4423d670812090611v715309adq3e9d2d95254e2e16@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 09, 2008 at 05:11:17PM +0300, Alexander Beregalov wrote:
>   CC      arch/ia64/hp/sim/simeth.o
> arch/ia64/hp/sim/simeth.c: In function 'simeth_probe1':
> arch/ia64/hp/sim/simeth.c:212: error: 'struct net_device' has no member named 'open'

[PATCH] simeth: convert to net_device_ops

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 arch/ia64/hp/sim/simeth.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -167,6 +167,15 @@ netdev_read(int fd, unsigned char *buf, unsigned int len)
 	return ia64_ssc(fd, __pa(buf), len, 0, SSC_NETDEV_RECV);
 }
 
+static const struct net_device_ops simeth_netdev_ops = {
+	.ndo_open		= simeth_open,
+	.ndo_stop		= simeth_close,
+	.ndo_start_xmit		= simeth_tx,
+	.ndo_get_stats		= simeth_get_stats,
+	.ndo_set_multicast_list	= set_multicast_list, /* not yet used */
+
+};
+
 /*
  * Function shared with module code, so cannot be in init section
  *
@@ -209,11 +218,7 @@ simeth_probe1(void)
 	local = netdev_priv(dev);
 	local->simfd = fd; /* keep track of underlying file descriptor */
 
-	dev->open		= simeth_open;
-	dev->stop		= simeth_close;
-	dev->hard_start_xmit	= simeth_tx;
-	dev->get_stats		= simeth_get_stats;
-	dev->set_multicast_list = set_multicast_list; /* no yet used */
+	dev->netdev_ops = &simeth_netdev_ops;
 
 	err = register_netdev(dev);
 	if (err) {
