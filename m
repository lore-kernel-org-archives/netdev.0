From: David Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] fix IGMP version number and timer printing for /proc/net/igmp
Date: Thu, 1 Apr 2004 12:39:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF8A04DEA3.0B35CEBD-ON88256E69.006BA1BD-88256E69.006BFC19@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4FADFF8272D8f9e8a93df938690918c07BBE4FADFF8272D"
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4FADFF8272D8f9e8a93df938690918c07BBE4FADFF8272D
Content-type: multipart/alternative;
	Boundary="1__=07BBE4FADFF8272D8f9e8a93df938690918c07BBE4FADFF8272D"

--1__=07BBE4FADFF8272D8f9e8a93df938690918c07BBE4FADFF8272D
Content-type: text/plain; charset=US-ASCII





Below are 2.4.x and 2.6.x patches that correctly print the IGMP
version number and print "0" for the timer value when a timer
is not running.

2.6.x in-line for viewing; both variants attached.

                        +-DLS

diff -ruN linux-2.6.5-rc3/net/ipv4/igmp.c linux-2.6.5-rc3F2/net/ipv4/igmp.c
--- linux-2.6.5-rc3/net/ipv4/igmp.c 2004-03-30 12:27:30.000000000 -0800
+++ linux-2.6.5-rc3F2/net/ipv4/igmp.c     2004-03-31 23:04:49.000000000 -0800
@@ -2225,7 +2225,9 @@
            struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
            char   *querier;
 #ifdef CONFIG_IP_MULTICAST
-           querier = IGMP_V1_SEEN(state->in_dev) ? "V1" : "V2";
+           querier = IGMP_V1_SEEN(state->in_dev) ? "V1" :
+                   IGMP_V2_SEEN(state->in_dev) ? "V2" :
+                   "V3";
 #else
            querier = "NONE";
 #endif
@@ -2238,7 +2240,9 @@
            seq_printf(seq,
                     "\t\t\t\t%08lX %5d %d:%08lX\t\t%d\n",
                     im->multiaddr, im->users,
-                    im->tm_running, jiffies_to_clock_t(im->timer.expires-jiffies), im->reporter);
+                    im->tm_running, im->tm_running ?
+                    jiffies_to_clock_t(im->timer.expires-jiffies) : 0,
+                    im->reporter);
      }
      return 0;
 }

(See attached file: 2.4.26rc1-igmpprint.patch)
(See attached file: 2.6.5rc3-igmpprint.patch)
--1__=07BBE4FADFF8272D8f9e8a93df938690918c07BBE4FADFF8272D
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Below are 2.4.x and 2.6.x patches that correctly print the IGMP<br>
version number and print &quot;0&quot; for the timer value when a timer<br>
is not running.<br>
<br>
2.6.x in-line for viewing; both variants attached.<br>
<br>
				+-DLS<br>
<br>
diff -ruN linux-2.6.5-rc3/net/ipv4/igmp.c linux-2.6.5-rc3F2/net/ipv4/igmp.c<br>
--- linux-2.6.5-rc3/net/ipv4/igmp.c	2004-03-30 12:27:30.000000000 -0800<br>
+++ linux-2.6.5-rc3F2/net/ipv4/igmp.c	2004-03-31 23:04:49.000000000 -0800<br>
@@ -2225,7 +2225,9 @@<br>
 		struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);<br>
 		char   *querier;<br>
 #ifdef CONFIG_IP_MULTICAST<br>
-		querier = IGMP_V1_SEEN(state-&gt;in_dev) ? &quot;V1&quot; : &quot;V2&quot;;<br>
+		querier = IGMP_V1_SEEN(state-&gt;in_dev) ? &quot;V1&quot; :<br>
+			  IGMP_V2_SEEN(state-&gt;in_dev) ? &quot;V2&quot; :<br>
+			  &quot;V3&quot;;<br>
 #else<br>
 		querier = &quot;NONE&quot;;<br>
 #endif<br>
@@ -2238,7 +2240,9 @@<br>
 		seq_printf(seq,<br>
 			   &quot;\t\t\t\t%08lX %5d %d:%08lX\t\t%d\n&quot;,<br>
 			   im-&gt;multiaddr, im-&gt;users,<br>
-			   im-&gt;tm_running, jiffies_to_clock_t(im-&gt;timer.expires-jiffies), im-&gt;reporter);<br>
+			   im-&gt;tm_running, im-&gt;tm_running ?<br>
+			   jiffies_to_clock_t(im-&gt;timer.expires-jiffies) : 0,<br>
+			   im-&gt;reporter);<br>
 	}<br>
 	return 0;<br>
 }<br>
<br>
<i>(See attached file: 2.4.26rc1-igmpprint.patch)</i><br>
<i>(See attached file: 2.6.5rc3-igmpprint.patch)</i><br>
</body></html>

--1__=07BBE4FADFF8272D8f9e8a93df938690918c07BBE4FADFF8272D--


--0__=07BBE4FADFF8272D8f9e8a93df938690918c07BBE4FADFF8272D
Content-type: application/octet-stream;
	name="2.4.26rc1-igmpprint.patch"
Content-Disposition: attachment; filename="2.4.26rc1-igmpprint.patch"
Content-ID: <10__=07BBE4FADFF8272D8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNC4yNi1yYzEvbmV0L2lwdjQvaWdtcC5jIGxpbnV4LTIuNC4yNi1y
YzFGMi9uZXQvaXB2NC9pZ21wLmMKLS0tIGxpbnV4LTIuNC4yNi1yYzEvbmV0L2lwdjQvaWdtcC5j
CTIwMDQtMDMtMzAgMTY6Mjg6MzkuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjQuMjYtcmMx
RjIvbmV0L2lwdjQvaWdtcC5jCTIwMDQtMDMtMzEgMjI6NDI6MzMuMDAwMDAwMDAwIC0wODAwCkBA
IC0yMTI4LDcgKzIxMjgsOCBAQAogCQkJY29udGludWU7CiAKICNpZmRlZiBDT05GSUdfSVBfTVVM
VElDQVNUCi0JCXF1ZXJpZXIgPSBJR01QX1YxX1NFRU4oaW5fZGV2KSA/ICJWMSIgOiAiVjIiOwor
CQlxdWVyaWVyID0gSUdNUF9WMV9TRUVOKGluX2RldikgPyAiVjEiIDogSUdNUF9WMl9TRUVOKGlu
X2RldikgPworCQkJIlYyIiA6ICJWMyI7CiAjZW5kaWYKIAogCQlsZW4rPXNwcmludGYoYnVmZmVy
K2xlbiwiJWRcdCUtMTBzOiAlNWQgJTdzXG4iLApAQCAtMjEzOSw3ICsyMTQwLDkgQEAKIAkJCWxl
bis9c3ByaW50ZihidWZmZXIrbGVuLAogCQkJCSAgICAgIlx0XHRcdFx0JTA4bFggJTVkICVkOiUw
OGxYXHRcdCVkXG4iLAogCQkJCSAgICAgaW0tPm11bHRpYWRkciwgaW0tPnVzZXJzLAotCQkJCSAg
ICAgaW0tPnRtX3J1bm5pbmcsIGltLT50aW1lci5leHBpcmVzLWppZmZpZXMsIGltLT5yZXBvcnRl
cik7CisJCQkJICAgICBpbS0+dG1fcnVubmluZywgaW0tPnRtX3J1bm5pbmcgPworCQkJCSAgICAg
aW0tPnRpbWVyLmV4cGlyZXMtamlmZmllcyA6IDAsCisJCQkJICAgICBpbS0+cmVwb3J0ZXIpOwog
CiAJCQlwb3M9YmVnaW4rbGVuOwogCQkJaWYocG9zPG9mZnNldCkK

--0__=07BBE4FADFF8272D8f9e8a93df938690918c07BBE4FADFF8272D
Content-type: application/octet-stream;
	name="2.6.5rc3-igmpprint.patch"
Content-Disposition: attachment; filename="2.6.5rc3-igmpprint.patch"
Content-ID: <20__=07BBE4FADFF8272D8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNi41LXJjMy9uZXQvaXB2NC9pZ21wLmMgbGludXgtMi42LjUtcmMz
RjIvbmV0L2lwdjQvaWdtcC5jCi0tLSBsaW51eC0yLjYuNS1yYzMvbmV0L2lwdjQvaWdtcC5jCTIw
MDQtMDMtMzAgMTI6Mjc6MzAuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYuNS1yYzNGMi9u
ZXQvaXB2NC9pZ21wLmMJMjAwNC0wMy0zMSAyMzowNDo0OS4wMDAwMDAwMDAgLTA4MDAKQEAgLTIy
MjUsNyArMjIyNSw5IEBACiAJCXN0cnVjdCBpZ21wX21jX2l0ZXJfc3RhdGUgKnN0YXRlID0gaWdt
cF9tY19zZXFfcHJpdmF0ZShzZXEpOwogCQljaGFyICAgKnF1ZXJpZXI7CiAjaWZkZWYgQ09ORklH
X0lQX01VTFRJQ0FTVAotCQlxdWVyaWVyID0gSUdNUF9WMV9TRUVOKHN0YXRlLT5pbl9kZXYpID8g
IlYxIiA6ICJWMiI7CisJCXF1ZXJpZXIgPSBJR01QX1YxX1NFRU4oc3RhdGUtPmluX2RldikgPyAi
VjEiIDoKKwkJCSAgSUdNUF9WMl9TRUVOKHN0YXRlLT5pbl9kZXYpID8gIlYyIiA6CisJCQkgICJW
MyI7CiAjZWxzZQogCQlxdWVyaWVyID0gIk5PTkUiOwogI2VuZGlmCkBAIC0yMjM4LDcgKzIyNDAs
OSBAQAogCQlzZXFfcHJpbnRmKHNlcSwKIAkJCSAgICJcdFx0XHRcdCUwOGxYICU1ZCAlZDolMDhs
WFx0XHQlZFxuIiwKIAkJCSAgIGltLT5tdWx0aWFkZHIsIGltLT51c2VycywKLQkJCSAgIGltLT50
bV9ydW5uaW5nLCBqaWZmaWVzX3RvX2Nsb2NrX3QoaW0tPnRpbWVyLmV4cGlyZXMtamlmZmllcyks
IGltLT5yZXBvcnRlcik7CisJCQkgICBpbS0+dG1fcnVubmluZywgaW0tPnRtX3J1bm5pbmcgPwor
CQkJICAgamlmZmllc190b19jbG9ja190KGltLT50aW1lci5leHBpcmVzLWppZmZpZXMpIDogMCwK
KwkJCSAgIGltLT5yZXBvcnRlcik7CiAJfQogCXJldHVybiAwOwogfQo=

--0__=07BBE4FADFF8272D8f9e8a93df938690918c07BBE4FADFF8272D--
