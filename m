From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH] mv643xx_eth: Fix ethtool stats
Date: Tue, 3 Oct 2006 10:27:10 -0700
Message-ID: <20061003172710.GA5906@xyzzy.farnsworth.org>
References: <1159893752.6580.27.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Dale Farnsworth <dale@farnsworth.org>,
	Manish Lachwani <mlachwani@mvista.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:64527 "HELO farnsworth.org")
	by vger.kernel.org with SMTP id S1030334AbWJCR1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 13:27:12 -0400
To: Maxime Bizon <mbizon@freebox.fr>
Content-Disposition: inline
In-Reply-To: <1159893752.6580.27.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxime Bizon <mbizon@freebox.fr>

Some stats reported by ethtool -S on mv643xx_eth device are cleared
between each call.  This patch fixes it.

Signed-off-by: Maxime Bizon <mbizon@freebox.fr>
Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

---

Thanks Maxime.

--- linux-2.6.18/drivers/net/mv643xx_eth.c.orig	2006-10-03 18:29:14.000000000 +0200
+++ linux-2.6.18/drivers/net/mv643xx_eth.c	2006-10-03 18:29:42.000000000 +0200
@@ -2156,7 +2156,7 @@
 	for (offset = ETH_MIB_BAD_OCTETS_RECEIVED;
 			offset <= ETH_MIB_FRAMES_1024_TO_MAX_OCTETS;
 			offset += 4)
-		*(u32 *)((char *)p + offset) = read_mib(mp, offset);
+		*(u32 *)((char *)p + offset) += read_mib(mp, offset);
 
 	p->good_octets_sent += read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_LOW);
 	p->good_octets_sent +=
@@ -2165,7 +2165,7 @@
 	for (offset = ETH_MIB_GOOD_FRAMES_SENT;
 			offset <= ETH_MIB_LATE_COLLISION;
 			offset += 4)
-		*(u32 *)((char *)p + offset) = read_mib(mp, offset);
+		*(u32 *)((char *)p + offset) += read_mib(mp, offset);
 }
 
 /*
