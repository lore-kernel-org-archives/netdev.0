From: David Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] UDP/IPv6 multicasting
Date: Fri, 14 Nov 2003 16:11:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF974281CA.F4EE30F2-ON88256DDE.007F34F9@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE74DDFECB2698f9e8a93df938690918c07BBE74DDFECB269"
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE74DDFECB2698f9e8a93df938690918c07BBE74DDFECB269
Content-type: text/plain; charset=US-ASCII





Dave,
      Below is a patch to fix a problem reported by Brian Buesker. When
binding to
two different multicast addresses on the same UDP port, a copy sent to
either multicast
address is delivered to both.

                        +-DLS

--- linux-2.6.0-test9-bk12/net/ipv6/udp.c 2003-11-07 14:13:21.000000000 -0800
+++ linux-2.6.0-test9-bk12F1/net/ipv6/udp.c     2003-11-14 14:51:05.000000000 -0800
@@ -551,6 +551,7 @@
                  if (!ipv6_addr_any(&np->rcv_saddr)) {
                        if (!ipv6_addr_cmp(&np->rcv_saddr, loc_addr))
                              return s;
+                       continue;
                  }
                  if(!inet6_mc_check(s, loc_addr, rmt_addr))
                        continue;

(See attached file: mcfix.patch.txt)
--0__=07BBE74DDFECB2698f9e8a93df938690918c07BBE74DDFECB269
Content-type: application/octet-stream;
	name="mcfix.patch.txt"
Content-Disposition: attachment; filename="mcfix.patch.txt"
Content-transfer-encoding: base64

LS0tIGxpbnV4LTIuNi4wLXRlc3Q5LWJrMTIvbmV0L2lwdjYvdWRwLmMJMjAwMy0xMS0wNyAxNDox
MzoyMS4wMDAwMDAwMDAgLTA4MDAKKysrIGxpbnV4LTIuNi4wLXRlc3Q5LWJrMTJGMS9uZXQvaXB2
Ni91ZHAuYwkyMDAzLTExLTE0IDE0OjUxOjA1LjAwMDAwMDAwMCAtMDgwMApAQCAtNTUxLDYgKzU1
MSw3IEBACiAJCQlpZiAoIWlwdjZfYWRkcl9hbnkoJm5wLT5yY3Zfc2FkZHIpKSB7CiAJCQkJaWYg
KCFpcHY2X2FkZHJfY21wKCZucC0+cmN2X3NhZGRyLCBsb2NfYWRkcikpCiAJCQkJCXJldHVybiBz
OworCQkJCWNvbnRpbnVlOwogCQkJfQogCQkJaWYoIWluZXQ2X21jX2NoZWNrKHMsIGxvY19hZGRy
LCBybXRfYWRkcikpCiAJCQkJY29udGludWU7Cg==

--0__=07BBE74DDFECB2698f9e8a93df938690918c07BBE74DDFECB269--
