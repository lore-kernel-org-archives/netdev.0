From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.7-mm1 3/4] via-velocity: ordering of Rx descriptors operations
Date: Mon, 21 Jun 2004 23:59:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040621235946.B9979@electric-eye.fr.zoreil.com>
References: <20040621235615.A7869@electric-eye.fr.zoreil.com> <20040621235808.A9979@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@redhat.com, akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040621235808.A9979@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Mon, Jun 21, 2004 at 11:58:08PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Force strict ordering of operations on Rx descriptors to avoid any issue
related to inline optimization.

diff -puN drivers/net/via-velocity.c~via-velocity-80 drivers/net/via-velocity.c
--- linux-2.6.7/drivers/net/via-velocity.c~via-velocity-80	2004-06-21 21:51:15.000000000 +0200
+++ linux-2.6.7-fr/drivers/net/via-velocity.c	2004-06-21 22:20:35.000000000 +0200
@@ -993,6 +993,8 @@ static inline void velocity_give_many_rx
 	if (vptr->rd_filled < 4)
 		return;
 
+	wmb();
+
 	unusable = vptr->rd_filled | 0x0003;
 	dirty = vptr->rd_dirty - unusable + 1;
 	for (avail = vptr->rd_filled & 0xfffc; avail; avail--) {

_
