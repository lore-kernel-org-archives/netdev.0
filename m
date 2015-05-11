From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH iproute2] man ip-link: Add missing lowpan link type
Date: Mon, 11 May 2015 10:17:14 +0300
Message-ID: <20150511071714.GP11014@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([148.251.232.15]:42374 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbbEKHZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 03:25:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>
---
These man pages don't use .nh when describing command invocation syntax=
,
so we end up with things like this (on 80 character terminals):

              ip link add DEVICE type vxlan id ID [ dev PHYS_DEV  ] [ {=
 group
              | remote } IPADDR ] [ local IPADDR ] [ ttl TTL ] [ tos TO=
S ] [
              port MIN MAX ] [ [no]learning ] [ [no]proxy ] [ [no]rsc ]=
 [
              [no]l2miss ] [ [no]l3miss ] [ ageing SECONDS ] [ maxaddre=
ss NUM=E2=80=90
              BER ] [ gbp ]

and:

              ip link add DEVICE type { gre | ipip | sit }  remote ADDR=
 local
              ADDR [ encap { fou | gue | none } ] [ encap-sport { PORT =
| auto
              } ] [ encap-dport PORT ] [  [no]encap-csum ] [  [no]encap=
-remc=E2=80=90
              sum ]

and this affects this addition as well:

       TYPE :=3D [ bridge | bond | can | dummy | hsr | ifb | ipoib | ma=
cvlan |
               macvtap | vcan | veth | vlan | vxlan | ip6tnl | ipip | s=
it |
               gre | gretap | ip6gre | ip6gretap | vti | nlmon | ipvlan=
 | low=E2=80=90
               pan ]

A possible fix for this would be to put these descriptions in an
environment with hyphenation mode zero.

 man/man8/ip-link.8.in | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 0dfcb2e..823246f 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -75,7 +75,8 @@ ip-link \- network device configuration
 .BR ip6gretap " |"
 .BR vti " |"
 .BR nlmon " |"
-.BR ipvlan " ]"
+.BR ipvlan " |"
+.BR lowpan " ]"
=20
 .ti -8
 .BR "ip link delete " {
@@ -243,6 +244,9 @@ Link types:
 .sp
 .BR ipvlan
 - Interface for L3 (IPv6/IPv4) based VLANs
+.sp
+.BR lowpan
+- Interface for 6LoWPAN (IPv6) over IEEE 802.15.4 / Bluetooth
 .in -8
=20
 .TP
@@ -916,6 +920,12 @@ Creates an IPIP that is encapsulated with Generic =
UDP Encapsulation,
 and the outer UDP checksum and remote checksum offload are enabled.
=20
 .RE
+.PP
+ip link add link wpan0 lowpan0 type lowpan
+.RS 4
+Creates a 6LoWPAN interface named lowpan0 on the underlying
+IEEE 802.15.4 device wpan0.
+.RE
=20
 .SH SEE ALSO
 .br
--=20
2.1.0
