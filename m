From: janitor@sternwelten.at
Subject: [patch 2/2]  linux-2.6.7/net/atm/mpc.c: add error check
Date: Sat, 20 Nov 2004 03:43:00 +0100
Message-ID: <E1CVLDJ-00028Y-3q@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, WHarms@bfs.de, wharms@bfs.de
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Content-type: text/plain; charset=us-ascii

add errorcheck for register_netdevice_notifier()

Signed-off-by: walter harms <wharms@bfs.de>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
---

 linux-2.6.10-rc2-bk4-max/net/atm/mpc.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

diff -puN net/atm/mpc.c~check-register_netdevice_notifier-net_atm_mpc net/atm/mpc.c
--- linux-2.6.10-rc2-bk4/net/atm/mpc.c~check-register_netdevice_notifier-net_atm_mpc	2004-11-20 03:04:37.000000000 +0100
+++ linux-2.6.10-rc2-bk4-max/net/atm/mpc.c	2004-11-20 03:04:37.000000000 +0100
@@ -761,7 +761,10 @@ int atm_mpoa_mpoad_attach (struct atm_vc
 		mpc_timer_refresh();
 
 		/* This lets us now how our LECs are doing */
-		register_netdevice_notifier(&mpoa_notifier);
+		if (register_netdevice_notifier(&mpoa_notifier) < 0) {
+			del_timer(&mpc_timer);
+			return -1;
+		}
 	}
 	
 	mpc = find_mpc_by_itfnum(arg);
_
