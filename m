From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: MLDv1 /proc/net/igmp6 timer printing [PATCH]
Date: Wed, 19 Nov 2003 00:59:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFC259A8D3.0F02136D-ON88256DE3.002BA960@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE770DFB82FF08f9e8a93df938690918c07BBE770DFB82FF0"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE770DFB82FF08f9e8a93df938690918c07BBE770DFB82FF0
Content-type: text/plain; charset=US-ASCII





Ok, here's the revised patch.

            +-DLS

--- linux-2.6.0-test9-bk23/net/ipv6/mcast.c     2003-11-18 23:20:56.000000000 -0800
+++ linux-2.6.0-test9-bk23F1/net/ipv6/mcast.c   2003-11-18 23:30:18.573414608 -0800
@@ -36,6 +36,7 @@
 #include <linux/socket.h>
 #include <linux/sockios.h>
 #include <linux/jiffies.h>
+#include <linux/times.h>
 #include <linux/net.h>
 #include <linux/in.h>
 #include <linux/in6.h>
@@ -978,6 +979,7 @@
      ma->mca_timer.expires = jiffies + delay;
      if (!mod_timer(&ma->mca_timer, jiffies + delay))
            atomic_inc(&ma->mca_refcnt);
+     ma->mca_flags |= MAF_TIMER_RUNNING;
 }

 static void mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
@@ -2157,7 +2159,8 @@
               state->dev->ifindex, state->dev->name,
               NIP6(im->mca_addr),
               im->mca_users, im->mca_flags,
-              (im->mca_flags&MAF_TIMER_RUNNING) ? im->mca_timer.expires-jiffies : 0);
+              (im->mca_flags&MAF_TIMER_RUNNING) ?
+              jiffies_to_clock_t(im->mca_timer.expires-jiffies) : 0);
      return 0;
 }

(See attached file: mld2tr2.patch)
--0__=07BBE770DFB82FF08f9e8a93df938690918c07BBE770DFB82FF0
Content-type: application/octet-stream;
	name="mld2tr2.patch"
Content-Disposition: attachment; filename="mld2tr2.patch"
Content-transfer-encoding: base64

LS0tIGxpbnV4LTIuNi4wLXRlc3Q5LWJrMjMvbmV0L2lwdjYvbWNhc3QuYwkyMDAzLTExLTE4IDIz
OjIwOjU2LjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi42LjAtdGVzdDktYmsyM0YxL25ldC9p
cHY2L21jYXN0LmMJMjAwMy0xMS0xOCAyMzozMDoxOC41NzM0MTQ2MDggLTA4MDAKQEAgLTM2LDYg
KzM2LDcgQEAKICNpbmNsdWRlIDxsaW51eC9zb2NrZXQuaD4KICNpbmNsdWRlIDxsaW51eC9zb2Nr
aW9zLmg+CiAjaW5jbHVkZSA8bGludXgvamlmZmllcy5oPgorI2luY2x1ZGUgPGxpbnV4L3RpbWVz
Lmg+CiAjaW5jbHVkZSA8bGludXgvbmV0Lmg+CiAjaW5jbHVkZSA8bGludXgvaW4uaD4KICNpbmNs
dWRlIDxsaW51eC9pbjYuaD4KQEAgLTk3OCw2ICs5NzksNyBAQAogCW1hLT5tY2FfdGltZXIuZXhw
aXJlcyA9IGppZmZpZXMgKyBkZWxheTsKIAlpZiAoIW1vZF90aW1lcigmbWEtPm1jYV90aW1lciwg
amlmZmllcyArIGRlbGF5KSkKIAkJYXRvbWljX2luYygmbWEtPm1jYV9yZWZjbnQpOworCW1hLT5t
Y2FfZmxhZ3MgfD0gTUFGX1RJTUVSX1JVTk5JTkc7CiB9CiAKIHN0YXRpYyB2b2lkIG1sZF9tYXJr
c291cmNlcyhzdHJ1Y3QgaWZtY2FkZHI2ICpwbWMsIGludCBuc3JjcywKQEAgLTIxNTcsNyArMjE1
OSw4IEBACiAJCSAgIHN0YXRlLT5kZXYtPmlmaW5kZXgsIHN0YXRlLT5kZXYtPm5hbWUsCiAJCSAg
IE5JUDYoaW0tPm1jYV9hZGRyKSwKIAkJICAgaW0tPm1jYV91c2VycywgaW0tPm1jYV9mbGFncywK
LQkJICAgKGltLT5tY2FfZmxhZ3MmTUFGX1RJTUVSX1JVTk5JTkcpID8gaW0tPm1jYV90aW1lci5l
eHBpcmVzLWppZmZpZXMgOiAwKTsKKwkJICAgKGltLT5tY2FfZmxhZ3MmTUFGX1RJTUVSX1JVTk5J
TkcpID8KKwkJICAgamlmZmllc190b19jbG9ja190KGltLT5tY2FfdGltZXIuZXhwaXJlcy1qaWZm
aWVzKSA6IDApOwogCXJldHVybiAwOwogfQogCg==

--0__=07BBE770DFB82FF08f9e8a93df938690918c07BBE770DFB82FF0--
