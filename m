From: David Stevens <dlstevens@us.ibm.com>
Subject: MLDv1 /proc/net/igmp6 timer printing [PATCH]
Date: Tue, 18 Nov 2003 21:55:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF8D427868.33352D02-ON88256DE3.001A7B55@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE770DF89FDC58f9e8a93df938690918c07BBE770DF89FDC5"
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE770DF89FDC58f9e8a93df938690918c07BBE770DF89FDC5
Content-type: text/plain; charset=US-ASCII





Dave,
      This is a bug, but mostly cosmetic, and it appears to have
been there forever. It wasted a couple minutes for me because I
expected the igmp6 file would list the timer correctly when it's
running, but because of this bug, it doesn't. Let me know if I should
hold it until later.
      The problem is the IPv6 multicast address flag
"MAF_TIMER_RUNNING" is set on a join_group, and cleared
by a report, but is never set again (e.g., from a query). The timer
is set and running, but the /proc entry won't show it because it
only reports the time left on the timer if the flag is set.
      Fix is to set the flag when the timer is set.

                        +-DLS

--- linux-2.6.0-test9-bk12/net/ipv6/mcast.c     2003-11-07 14:13:21.000000000 -0800
+++ linux-2.6.0-test9-bk12F1/net/ipv6/mcast.c   2003-11-18 20:38:00.000000000 -0800
@@ -978,6 +978,7 @@
      ma->mca_timer.expires = jiffies + delay;
      if (!mod_timer(&ma->mca_timer, jiffies + delay))
            atomic_inc(&ma->mca_refcnt);
+     ma->mca_flags |= MAF_TIMER_RUNNING;
 }

 static void mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,

(See attached file: mldtr.patch)
--0__=07BBE770DF89FDC58f9e8a93df938690918c07BBE770DF89FDC5
Content-type: application/octet-stream;
	name="mldtr.patch"
Content-Disposition: attachment; filename="mldtr.patch"
Content-transfer-encoding: base64

LS0tIGxpbnV4LTIuNi4wLXRlc3Q5LWJrMTIvbmV0L2lwdjYvbWNhc3QuYwkyMDAzLTExLTA3IDE0
OjEzOjIxLjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi42LjAtdGVzdDktYmsxMkYxL25ldC9p
cHY2L21jYXN0LmMJMjAwMy0xMS0xOCAyMDozODowMC4wMDAwMDAwMDAgLTA4MDAKQEAgLTk3OCw2
ICs5NzgsNyBAQAogCW1hLT5tY2FfdGltZXIuZXhwaXJlcyA9IGppZmZpZXMgKyBkZWxheTsKIAlp
ZiAoIW1vZF90aW1lcigmbWEtPm1jYV90aW1lciwgamlmZmllcyArIGRlbGF5KSkKIAkJYXRvbWlj
X2luYygmbWEtPm1jYV9yZWZjbnQpOworCW1hLT5tY2FfZmxhZ3MgfD0gTUFGX1RJTUVSX1JVTk5J
Tkc7CiB9CiAKIHN0YXRpYyB2b2lkIG1sZF9tYXJrc291cmNlcyhzdHJ1Y3QgaWZtY2FkZHI2ICpw
bWMsIGludCBuc3JjcywK

--0__=07BBE770DF89FDC58f9e8a93df938690918c07BBE770DF89FDC5--
