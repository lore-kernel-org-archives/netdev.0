From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for August 23 (networking)
Date: Mon, 23 Aug 2010 20:42:44 -0700 (PDT)
Message-ID: <20100823.204244.216743717.davem@davemloft.net>
References: <20100823133738.f0a45152.sfr@canb.auug.org.au>
	<20100823175044.9210f050.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100823175044.9210f050.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 23 Aug 2010 17:50:44 -0700

> ERROR: "ip_send_check" [net/sched/act_csum.ko] undefined!

I've applied the following to fix this:

--------------------
pkt_sched: Make act_csum depend upon INET.

It uses ip_send_check() and stuff like that.

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 522d5a9..a36270a 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -520,7 +520,7 @@ config NET_ACT_SKBEDIT
 
 config NET_ACT_CSUM
         tristate "Checksum Updating"
-        depends on NET_CLS_ACT
+        depends on NET_CLS_ACT && INET
         ---help---
 	  Say Y here to update some common checksum after some direct
 	  packet alterations.
-- 
1.7.2.2
