From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC] TCP congestion schedulers
Date: Tue, 15 Mar 2005 17:16:19 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0503151714180.6669@dexter.psc.edu>
References: <421CF5E5.1060606@ev-en.org> <20050223135732.39e62c6c.davem@davemloft.net>
 <421D1E66.5090301@osdl.org> <421D30FA.1060900@ev-en.org>
 <20050225120814.5fa77b13@dxpl.pdx.osdl.net> <20050309210442.3e9786a6.davem@davemloft.net>
 <4230288F.1030202@ev-en.org> <20050310182629.1eab09ec.davem@davemloft.net>
 <20050311120054.4bbf675a@dxpl.pdx.osdl.net> <20050311201011.360c00da.davem@davemloft.net>
 <20050314151726.532af90d@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, baruch@ev-en.org,
        netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050314151726.532af90d@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This fixes a null pointer dereference when closing listen sockets.

  -John


===== include/net/tcp.h 1.107 vs 1.108 =====
--- 1.107/include/net/tcp.h	Tue Mar 15 15:12:54 2005
+++ 1.108/include/net/tcp.h	Tue Mar 15 17:09:48 2005
@@ -1219,7 +1219,7 @@

 static inline void tcp_set_ca_state(struct tcp_sock *tp, u8 ca_state)
 {
-	if (tp->ca_proto->set_state)
+	if (tp->ca_proto && tp->ca_proto->set_state)
 		tp->ca_proto->set_state(tp, ca_state);
 	tp->ca_state = ca_state;
 }
