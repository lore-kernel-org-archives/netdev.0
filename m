From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] Check if user has CAP_NET_ADMIN to change congestion control algorithm
Date: Fri, 27 Oct 2006 12:43:11 +0200
Message-ID: <20061027104311.GB3967@c3po.0xdef.net>
References: <4540F076.70801@psc.edu> <20061026224407.GA2018@c3po.0xdef.net> <20061026235256.GB2018@c3po.0xdef.net> <20061026.170221.99202188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: hagen@jauu.net, jheffner@psc.edu, shemminger@osdl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from c3po.0xdef.net ([217.172.181.57]:43023 "EHLO c3po.0xdef.net")
	by vger.kernel.org with ESMTP id S1946267AbWJ0KnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 06:43:12 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061026.170221.99202188.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller | 2006-10-26 17:02:21 [-0700]:

>Your email client turned the tabs into spaces in the patch making it
>useless.

Sorry my mistake! I am en route and I paste the patch into my editor, who eat
all tabs. One more time: sorry!


Check if user has CAP_NET_ADMIN capability to change
congestion control algorithm.


Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

---
 net/ipv4/tcp_cong.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index af0aca1..c1ae2e9 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -10,6 +10,7 @@ #include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/types.h>
 #include <linux/list.h>
+#include <linux/capability.h>
 #include <net/tcp.h>
 
 static DEFINE_SPINLOCK(tcp_cong_list_lock);
@@ -151,6 +152,9 @@ int tcp_set_congestion_control(struct so
 	struct tcp_congestion_ops *ca;
 	int err = 0;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	rcu_read_lock();
 	ca = tcp_ca_find(name);
 	if (ca == icsk->icsk_ca_ops)
-- 
1.4.1.1
