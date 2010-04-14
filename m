From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Bug#572201: [PATCH] forcedeth: fix tx limit2 flag check
Date: Wed, 14 Apr 2010 01:31:26 -0400
Message-ID: <4BC5532E.7000302@nvidia.com>
References: <1271160298.2098.0.camel@achroite.uk.solarflarecom.com>	<4BC47F38.5040509@gmail.com>	<1271169741.16881.437.camel@edumazet-laptop> <20100413.144340.138717714.davem@davemloft.net>
Reply-To: Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080107020308080805040101"
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
 "smulcahy@gmail.com" <smulcahy@gmail.com>,
 "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "ben@decadent.org.uk" <ben@decadent.org.uk>,
 "572201@bugs.debian.org" <572201@bugs.debian.org>
To: David Miller <davem@davemloft.net>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.572201.B572201.127120903829243@bugs.debian.org>
In-Reply-To: <20100413.144340.138717714.davem@davemloft.net>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080107020308080805040101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes the TX_LIMIT feature flag. The previous logic check for 
TX_LIMIT2 also took into account a device that only had TX_LIMIT set.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

This is a fix for bug 572201 @ bugs.debian.org





--------------080107020308080805040101
Content-Type: text/plain;
 name="patch-forcedeth-tx-limit2-fix"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-tx-limit2-fix"

--- old/drivers/net/forcedeth.c	2010-04-14 01:18:51.000000000 -0400
+++ new/drivers/net/forcedeth.c	2010-04-14 01:20:40.000000000 -0400
@@ -5901,7 +5901,7 @@
 	/* Limit the number of tx's outstanding for hw bug */
 	if (id->driver_data & DEV_NEED_TX_LIMIT) {
 		np->tx_limit = 1;
-		if ((id->driver_data & DEV_NEED_TX_LIMIT2) &&
+		if (((id->driver_data & DEV_NEED_TX_LIMIT2) == DEV_NEED_TX_LIMIT2) &&
 		    pci_dev->revision >= 0xA2)
 			np->tx_limit = 0;
 	}

--------------080107020308080805040101--
