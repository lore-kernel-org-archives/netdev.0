From: David Howells <dhowells@redhat.com>
Subject: [PATCH 06/13] rxrpc: Fix defined range for
 /proc/sys/net/rxrpc/rx_mtu
Date: Fri, 04 Mar 2016 16:37:47 +0000
Message-ID: <20160304163747.31057.42979.stgit@warthog.procyon.org.uk>
References: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The upper bound of the defined range for rx_mtu is being set in the same
member as the lower bound (extra1) rather than the correct place (extra2).
I'm not entirely sure why this compiles.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/sysctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/sysctl.c b/net/rxrpc/sysctl.c
index 50a98a910eb1..093547ac2bcd 100644
--- a/net/rxrpc/sysctl.c
+++ b/net/rxrpc/sysctl.c
@@ -115,7 +115,7 @@ static struct ctl_table rxrpc_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= (void *)&one,
-		.extra1		= (void *)&n_65535,
+		.extra2		= (void *)&n_65535,
 	},
 	{
 		.procname	= "rx_jumbo_max",
