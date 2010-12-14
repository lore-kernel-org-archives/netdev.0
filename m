From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 01/22] netconsole: Remove unneeded reference counting
Date: Tue, 14 Dec 2010 13:28:58 -0800
Message-ID: <20101214212858.17022.78664.stgit@mike.mtv.corp.google.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: adurbin@google.com, linux-kernel@vger.kernel.org,
	chavey@google.com, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org,
	=?utf-8?q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	akpm@linux-foundation.org, linux-api@vger.kernel.org
To: simon.kagstrom@netinsight.net, davem@davemloft.net,
	nhorman@tuxdriver.com, Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The loops that iterate through the list of targets for emitting console
messages in the netconsole driver operating with interrupts disabled and
the list-protecting lock held.  There is no way for the elements of the
list to disappear, so we don't need to grab references to them.

This patch keeps the definitions however of netconsole_target_get() and
netconsole_target_put() as they are used in a subsequent patch.

Signed-off-by: Mike Waychison <mikew@google.com>
Acked-by: Matt Mackall <mpm@selenic.com>
---
 drivers/net/netconsole.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 94255f0..c87a49e 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -671,7 +671,6 @@ static int netconsole_netdev_event(struct notifier_block *this,
 
 	spin_lock_irqsave(&target_list_lock, flags);
 	list_for_each_entry(nt, &target_list, list) {
-		netconsole_target_get(nt);
 		if (nt->np.dev == dev) {
 			switch (event) {
 			case NETDEV_CHANGENAME:
@@ -693,7 +692,6 @@ static int netconsole_netdev_event(struct notifier_block *this,
 				break;
 			}
 		}
-		netconsole_target_put(nt);
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
 	if (event == NETDEV_UNREGISTER || event == NETDEV_BONDING_DESLAVE)
@@ -722,7 +720,6 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 
 	spin_lock_irqsave(&target_list_lock, flags);
 	list_for_each_entry(nt, &target_list, list) {
-		netconsole_target_get(nt);
 		if (nt->enabled && netif_running(nt->np.dev)) {
 			/*
 			 * We nest this inside the for-each-target loop above
@@ -738,7 +735,6 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 				left -= frag;
 			}
 		}
-		netconsole_target_put(nt);
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
 }
