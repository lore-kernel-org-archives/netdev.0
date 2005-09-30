From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH 09/10] [PATCH] tcp: set default congestion control correctly for incoming connections
Date: Thu, 29 Sep 2005 19:20:25 -0700
Message-ID: <20050930022249.667419000@localhost.localdomain>
References: <20050930022016.640197000@localhost.localdomain>
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Chuck Wolber <chuckw@quantumlinux.com>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, Joel Sing <joel@ionix.com.au>,
	Chris Wright <chrisw@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932551AbVI3CY3@vger.kernel.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	"David S. Miller" <davem@davemloft.net>
Content-Disposition: inline; filename=tcp-set-default-congestion-control-correctly.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.
------------------

Patch from Joel Sing to fix the default congestion control algorithm for incoming connections. If a new congestion control handler is added (via module),
it should become the default for new connections. Instead, the incoming
connections use reno. The cause is incorrect 
initialisation causes the tcp_init_congestion_control() function to return 
after the initial if test fails.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
Acked-by: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Chris Wright <chrisw@osdl.org>
---
 net/ipv4/tcp_minisocks.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.13.y/net/ipv4/tcp_minisocks.c
===================================================================
--- linux-2.6.13.y.orig/net/ipv4/tcp_minisocks.c
+++ linux-2.6.13.y/net/ipv4/tcp_minisocks.c
@@ -774,7 +774,7 @@ struct sock *tcp_create_openreq_child(st
 		newtp->frto_counter = 0;
 		newtp->frto_highmark = 0;
 
-		newtp->ca_ops = &tcp_reno;
+		newtp->ca_ops = &tcp_init_congestion_ops;
 
 		tcp_set_ca_state(newtp, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);

--
