From: David Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] bug in ARP override timer near jiffies wrap
Date: Fri, 7 May 2004 14:01:10 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF2E0715FD.603FFEE2-ON88256E8D.006DBE22-88256E8D.006DF160@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 006DF15888256E8D_="
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=_mixed 006DF15888256E8D_=
Content-Type: text/plain; charset="US-ASCII"

This patch fixes the calculation of "override" in ARP.

                                +-DLS

--- linux-2.6.6-rc2F1/net/ipv4/arp.c    2004-04-21 15:47:55.000000000 
-0700
+++ linux-2.6.6-rc2F2/net/ipv4/arp.c    2004-05-07 12:54:34.898406424 
-0700
@@ -891,15 +891,14 @@
 
        if (n) {
                int state = NUD_REACHABLE;
-               int override = 0;
+               int override;
 
                /* If several different ARP replies follows back-to-back,
                   use the FIRST one. It is possible, if several proxy
                   agents are active. Taking the first reply prevents
                   arp trashing and chooses the fastest router.
                 */
-               if (jiffies - n->updated >= n->parms->locktime)
-                       override = 1;
+               override = time_after(jiffies, n->updated + 
n->parms->locktime);
 
                /* Broadcast replies and request packets
                   do not assert neighbour reachability.


--=_mixed 006DF15888256E8D_=
Content-Type: application/octet-stream; name="arpfix.patch"
Content-Disposition: attachment; filename="arpfix.patch"
Content-Transfer-Encoding: base64

LS0tIGxpbnV4LTIuNi42LXJjMkYxL25ldC9pcHY0L2FycC5jCTIwMDQtMDQtMjEgMTU6NDc6NTUu
MDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuNi1yYzJGMi9uZXQvaXB2NC9hcnAuYwkyMDA0
LTA1LTA3IDEyOjU0OjM0Ljg5ODQwNjQyNCAtMDcwMApAQCAtODkxLDE1ICs4OTEsMTQgQEAKIAog
CWlmIChuKSB7CiAJCWludCBzdGF0ZSA9IE5VRF9SRUFDSEFCTEU7Ci0JCWludCBvdmVycmlkZSA9
IDA7CisJCWludCBvdmVycmlkZTsKIAogCQkvKiBJZiBzZXZlcmFsIGRpZmZlcmVudCBBUlAgcmVw
bGllcyBmb2xsb3dzIGJhY2stdG8tYmFjaywKIAkJICAgdXNlIHRoZSBGSVJTVCBvbmUuIEl0IGlz
IHBvc3NpYmxlLCBpZiBzZXZlcmFsIHByb3h5CiAJCSAgIGFnZW50cyBhcmUgYWN0aXZlLiBUYWtp
bmcgdGhlIGZpcnN0IHJlcGx5IHByZXZlbnRzCiAJCSAgIGFycCB0cmFzaGluZyBhbmQgY2hvb3Nl
cyB0aGUgZmFzdGVzdCByb3V0ZXIuCiAJCSAqLwotCQlpZiAoamlmZmllcyAtIG4tPnVwZGF0ZWQg
Pj0gbi0+cGFybXMtPmxvY2t0aW1lKQotCQkJb3ZlcnJpZGUgPSAxOworCQlvdmVycmlkZSA9IHRp
bWVfYWZ0ZXIoamlmZmllcywgbi0+dXBkYXRlZCArIG4tPnBhcm1zLT5sb2NrdGltZSk7CiAKIAkJ
LyogQnJvYWRjYXN0IHJlcGxpZXMgYW5kIHJlcXVlc3QgcGFja2V0cwogCQkgICBkbyBub3QgYXNz
ZXJ0IG5laWdoYm91ciByZWFjaGFiaWxpdHkuCg==
--=_mixed 006DF15888256E8D_=--
