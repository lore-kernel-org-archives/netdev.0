From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH] bug in xfrm_lookup [bugzilla 2017]
Date: Wed, 4 Feb 2004 17:41:48 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402041735320.6034-100000@DYN318430BLD.beaverton.ibm.com>
References: <20040119211156.4bff1640.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040119211156.4bff1640.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

One of my earlier patches had a bug in xfrm_lookup() causin schedule()
to get called though MSG_DONTWAIT was specified. I am going to send
the following patch to the bugzilla user who created this bug report
and ask them to test it. I thought I will let you know of this problem
and I will send you a confirmation once I get a response that the problem
is solved.

Thanks,

- KK

diff -ruN linux-2.6.2/net/xfrm/xfrm_policy.c linux-2.6.2.new/net/xfrm/xfrm_policy.c
--- linux-2.6.2/net/xfrm/xfrm_policy.c	2004-02-04 17:33:51.000000000 -0800
+++ linux-2.6.2.new/net/xfrm/xfrm_policy.c	2004-02-04 17:34:37.000000000 -0800
@@ -775,7 +775,7 @@

 		if (unlikely(nx<0)) {
 			err = nx;
-			if (err == -EAGAIN && !flags) {
+			if (err == -EAGAIN && flags) {
 				DECLARE_WAITQUEUE(wait, current);

 				add_wait_queue(&km_waitq, &wait);
