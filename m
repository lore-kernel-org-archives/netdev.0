From: Greg KH <gregkh@suse.de>
Subject: [patch 11/22] net: eliminate warning from NETIF_F_UFO on bridge
Date: Tue, 16 Dec 2008 16:04:21 -0800
Message-ID: <20081217000421.GL4504@kroah.com>
References: <20081216235704.347182084@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>, Willy Tarreau <w@1wt.eu>,
	Rodrigo Rubira Branco <rbranco@la.checkpoint.com>,
	Jake Edge <jake@lwn.net>, Eugene Teo <eteo@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:41292 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759346AbYLQAGD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 19:06:03 -0500
Content-Disposition: inline; filename="net-eliminate-warning-from-netif_f_ufo-on-bridge.patch"
In-Reply-To: <20081217000306.GA4504@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.27-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Stephen Hemminger <shemminger@vyatta.com>

Based on commit b63365a2d60268a3988285d6c3c6003d7066f93a upstream, but
drastically cut down for 2.6.27.y

The bridge device always causes a warning because when it is first created
it has the no checksum flag set along with all the segmentation/fragmentation
offload bits.  The code in register_netdevice incorrectly checks for only
hardware checksum bit and ignores no checksum bit.

Similar code is already in 2.6.28:
   commit b63365a2d60268a3988285d6c3c6003d7066f93a
   net: Fix disjunct computation of netdev features

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Cc: David Miller <davem@davemloft.net>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3990,7 +3990,7 @@ int register_netdevice(struct net_device
 		dev->features &= ~NETIF_F_TSO;
 	}
 	if (dev->features & NETIF_F_UFO) {
-		if (!(dev->features & NETIF_F_HW_CSUM)) {
+		if (!(dev->features & NETIF_F_GEN_CSUM)) {
 			printk(KERN_ERR "%s: Dropping NETIF_F_UFO since no "
 					"NETIF_F_HW_CSUM feature.\n",
 							dev->name);

