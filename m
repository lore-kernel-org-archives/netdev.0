From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH 1/5] ipcomp_tunnel_create doesn't set tunnel state
Date: Tue, 13 Jan 2004 13:21:19 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
References: <20040110121134.08481951.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Krishna Kumar <krkumar@us.ibm.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040110121134.08481951.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> > Or should I send separate patches this time ?
>
> I think this would be a good idea.

ipcomp_tunnel_create doesn't set x->km.state to XFRM_STATE_DEAD. This can lead
to the BUG_TRAP in __xfrm_state_destroy when xfrm_state_put() finds this is
the last reference. This was reported as one of the symptoms of [Bug 1754]
some time back.

thanks,

- KK

diff -ruN linux-2.6.0-rc2-bk6.org/net/ipv4/ipcomp.c linux-2.6.0-rc2-bk6/net/ipv4/ipcomp.c
--- linux-2.6.0-rc2-bk6.org/net/ipv4/ipcomp.c	2004-01-05 13:43:50.000000000 -0800
+++ linux-2.6.0-rc2-bk6/net/ipv4/ipcomp.c	2004-01-09 13:00:22.000000000 -0800
@@ -294,6 +294,7 @@
 	return t;

 error:
+	t->km.state = XFRM_STATE_DEAD;
 	xfrm_state_put(t);
 	t = NULL;
 	goto out;
