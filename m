From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH 4/5] xfrm_state_construct doesn't set tunnel state
Date: Tue, 13 Jan 2004 13:24:23 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401131323410.25742-100000@linux-udp14999547uds>
References: <Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, KK <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.44.0401131319510.25742-100000@linux-udp14999547uds>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


xfrm_state_construct doesn't set x->km.state to XFRM_STATE_DEAD. This can lead
to the BUG_TRAP in __xfrm_state_destroy when xfrm_state_put() finds this is
the last reference. This was reported as one of the symptoms of [Bug 1754]
some time back.

thanks,

- KK

diff -ruN linux-2.6.0-rc2-bk6.org/net/xfrm/xfrm_user.c linux-2.6.0-rc2-bk6/net/xfrm/xfrm_user.c
--- linux-2.6.0-rc2-bk6.org/net/xfrm/xfrm_user.c	2004-01-09 12:57:42.000000000 -0800
+++ linux-2.6.0-rc2-bk6/net/xfrm/xfrm_user.c	2004-01-09 12:59:00.000000000 -0800
@@ -241,6 +241,7 @@
 	return x;

 error:
+	x->km.state = XFRM_STATE_DEAD;
 	xfrm_state_put(x);
 error_no_put:
 	*errp = err;
