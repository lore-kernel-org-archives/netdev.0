From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 3/3] 2.6.5-netdev2 - r8169 update
Date: Wed, 7 Apr 2004 23:16:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040407231611.C25867@electric-eye.fr.zoreil.com>
References: <20040405235545.A20805@electric-eye.fr.zoreil.com> <20040407231332.A25021@electric-eye.fr.zoreil.com> <20040407231444.A25867@electric-eye.fr.zoreil.com> <20040407231529.B25867@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040407231529.B25867@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Wed, Apr 07, 2004 at 11:15:29PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


mod_timer() expects an absolute time, not a relative offset.


 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/r8169.c~r8169-mod_timer drivers/net/r8169.c
--- linux-2.6.5/drivers/net/r8169.c~r8169-mod_timer	2004-04-07 22:59:15.000000000 +0200
+++ linux-2.6.5-fr/drivers/net/r8169.c	2004-04-07 22:59:15.000000000 +0200
@@ -617,7 +617,7 @@ static void rtl8169_phy_timer(unsigned l
 		}
 	}
 
-	mod_timer(timer, RTL8169_PHY_TIMEOUT);
+	mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
 }
 
 static inline void rtl8169_delete_timer(struct net_device *dev)

_
