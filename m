From: Guennadi Liakhovetski <lg@denx.de>
Subject: [PATCH] smc911x: Fix external PHY detection
Date: Sat, 11 Oct 2008 23:10:58 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0810112309410.4965@axis700.grange>
References: <OFFEAB9876.D4A121DB-ON802574BF.0052D905-802574BF.0054D4AE@smsc.com>
 <87vdx5gjzo.fsf@macbook.be.48ers.dk> <Pine.LNX.4.64.0810110125540.10196@axis700.grange>
 <871vynr3yb.fsf@macbook.be.48ers.dk> <Pine.LNX.4.64.0810111057030.4425@axis700.grange>
 <87k5cfoz7b.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Steve.Glendinning@smsc.com, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:55685 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1760717AbYJKVK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2008 17:10:58 -0400
In-Reply-To: <87k5cfoz7b.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an external PHY is found the driver falls through to the default
case in the switch and overwrites the PHY ID. Add the missing break.

Signed-off-by: Guennadi Liakhovetski <lg@denx.de>
---
against 2.6.27

 drivers/net/smc911x.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index c587162..dbc51e9 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -722,6 +722,9 @@ static void smc911x_phy_detect(struct net_device *dev)
 						break;
 					}
 				}
+				if (phyaddr < 32)
+					/* Found an external PHY */
+					break;
 			}
 		default:
 			/* Internal media only */
-- 
1.5.4

