From: Suresh Krishnan <suresh.krishnan@ericsson.ca>
Subject: [PATCH 2.6.9] address family not supported for sendmsg()
Date: Fri, 22 Oct 2004 00:27:14 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <21A5F45EFF209A44B3057E35CE1FE6E403981824-100000@eammlex037.lmc.ericsson.se>
Reply-To: Suresh Krishnan <suresh.krishnan@ericsson.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When sendmsg() encounters an unsupported address family
it must return EAFNOSUPPORT. It currently returns EINVAL,
which must be returned only when the sum of the iov_len 
values overflows a ssize_t.

Signed-off-by: Suresh Krishnan <suresh.krishnan@ericsson.ca>
---

diff -Nur linux-2.6.9/net/ipv4/raw.c linux-2.6.9-patched/net/ipv4/raw.c
--- linux-2.6.9/net/ipv4/raw.c  2004-10-18 17:54:31.000000000 -0400
+++ linux-2.6.9-patched/net/ipv4/raw.c  2004-10-21 16:38:15.000000000 -0400
@@ -407,7 +407,7 @@
                                printk(KERN_INFO "%s forgot to set AF_INET in "
                                                 "raw sendmsg. Fix it!\n",
                                                 current->comm);
-                       err = -EINVAL;
+                       err = -EAFNOSUPPORT;
                        if (usin->sin_family)
                                goto out;
                }
diff -Nur linux-2.6.9/net/ipv4/udp.c linux-2.6.9-patched/net/ipv4/udp.c
--- linux-2.6.9/net/ipv4/udp.c  2004-10-18 17:53:22.000000000 -0400
+++ linux-2.6.9-patched/net/ipv4/udp.c  2004-10-21 16:37:40.000000000 -0400
@@ -531,7 +531,7 @@
                        return -EINVAL;
                if (usin->sin_family != AF_INET) {
                        if (usin->sin_family != AF_UNSPEC)
-                               return -EINVAL;
+                               return -EAFNOSUPPORT;
                }

                daddr = usin->sin_addr.s_addr;
diff -Nur linux-2.6.9/net/ipv6/raw.c linux-2.6.9-patched/net/ipv6/raw.c
--- linux-2.6.9/net/ipv6/raw.c  2004-10-18 17:53:51.000000000 -0400
+++ linux-2.6.9-patched/net/ipv6/raw.c  2004-10-21 16:38:00.000000000 -0400
@@ -639,7 +639,7 @@
                        return -EINVAL;

                if (sin6->sin6_family && sin6->sin6_family != AF_INET6)
-                       return(-EINVAL);
+                       return(-EAFNOSUPPORT);

                /* port is the proto value [0..255] carried in nexthdr */
                proto = ntohs(sin6->sin6_port);
diff -Nur linux-2.6.9/net/ipv6/udp.c linux-2.6.9-patched/net/ipv6/udp.c
--- linux-2.6.9/net/ipv6/udp.c  2004-10-18 17:54:55.000000000 -0400
+++ linux-2.6.9-patched/net/ipv6/udp.c  2004-10-21 16:37:52.000000000 -0400
@@ -699,7 +699,7 @@
                if (likely(up->pending)) {
                        if (unlikely(up->pending != AF_INET6)) {
                                release_sock(sk);
-                               return -EINVAL;
+                               return -EAFNOSUPPORT;
                        }
                        dst = NULL;
                        goto do_append_data;
