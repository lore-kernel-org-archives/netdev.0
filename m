From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] drivers/net/bonding: Adjust constant name
Date: Sat, 11 Jul 2009 13:03:55 -0700
Message-ID: <9220.1247342635@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0907111006090.29592@ask.diku.dk>
Cc: bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:33583 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752849AbZGKUDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jul 2009 16:03:54 -0400
In-reply-to: <Pine.LNX.4.64.0907111006090.29592@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Julia Lawall <julia@diku.dk>

AD_SHORT_TIMEOUT and AD_STATE_LACP_ACTIVITY have the same value, but
AD_STATE_LACP_ACTIVITY better reflects the intended semantics.

[ J adds: AD_STATE_LACP_ACTIVITY is a value defined by the standard, and
should be set here in accordance with 802.3ad 43.4.12; AD_SHORT_TIMEOUT
is a constant specific to the Linux 802.3ad implementation that happens
to have the same value ]

The semantic match that finds this problem is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
struct port_params p;
@@
* p.port_state |= AD_SHORT_TIMEOUT
// </smpl>


Signed-off-by: Julia Lawall <julia@diku.dk>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

---
 drivers/net/bonding/bond_3ad.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index d4b5708..88a1446 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1109,7 +1109,8 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
 			//mux machine in case of EXPIRED even if LINK_DOWN didn't arrive for the port.
 			port->partner_oper.port_state &= ~AD_STATE_SYNCHRONIZATION;
 			port->sm_vars &= ~AD_PORT_MATCHED;
-			port->partner_oper.port_state |= AD_SHORT_TIMEOUT;
+			port->partner_oper.port_state |=
+				AD_STATE_LACP_ACTIVITY;
 			port->sm_rx_timer_counter = __ad_timer_to_ticks(AD_CURRENT_WHILE_TIMER, (u16)(AD_SHORT_TIMEOUT));
 			port->actor_oper_port_state |= AD_STATE_EXPIRED;
 			break;
