From: "Martin Schiller" <mschiller@tdt.de>
Subject: [PATCH] NAT and requests to unrouted targets
Date: Thu, 15 Mar 2007 09:03:22 +0100
Message-ID: <000001c766d8$66f1cc00$1a04010a@V505CP>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0001_01C766E0.C8B63400"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.tdt.de ([195.243.126.82]:40807 "EHLO ns.tdt.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932356AbXCOIQG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 04:16:06 -0400
Received: from ns (root@localhost)
	by ns.tdt.de (8.11.6/8.11.6/SuSE Linux 0.5) with SMTP id l2F83L502610
	for <netdev@vger.kernel.org>; Thu, 15 Mar 2007 09:03:21 +0100
Received: from V505CP (mschiller3 [10.1.4.26])
	by ns.tdt.de (8.11.6/8.11.6/SuSE Linux 0.5) with ESMTP id l2F83Lm02602
	for <netdev@vger.kernel.org>; Thu, 15 Mar 2007 09:03:21 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0001_01C766E0.C8B63400
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patch changes the behaivor of the iptables nat module to the style
before release 2.6.16 so it is possible again to use the "ping -I <iface>
<target>" command to send icmp requests to a target for which no route
exists.

Signed-off-by: Martin Schiller <mschiller@tdt.de>

------=_NextPart_000_0001_01C766E0.C8B63400
Content-Type: application/octet-stream;
	name="iptables_nat_unrouted_ping.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="iptables_nat_unrouted_ping.patch"

diff -uNpr linux-2.6.19.org/net/ipv4/netfilter/ip_nat_standalone.c =
linux-2.6.19/net/ipv4/netfilter/ip_nat_standalone.c=0A=
--- linux-2.6.19.org/net/ipv4/netfilter/ip_nat_standalone.c	2006-11-29 =
22:57:37.000000000 +0100=0A=
+++ linux-2.6.19/net/ipv4/netfilter/ip_nat_standalone.c	2007-03-15 =
08:25:11.000000000 +0100=0A=
@@ -191,11 +191,13 @@ ip_nat_in(unsigned int hooknum,=0A=
           int (*okfn)(struct sk_buff *))=0A=
 {=0A=
 	unsigned int ret;=0A=
+	__be32 saddr =3D (*pskb)->nh.iph->saddr;=0A=
 	__be32 daddr =3D (*pskb)->nh.iph->daddr;=0A=
 =0A=
 	ret =3D ip_nat_fn(hooknum, pskb, in, out, okfn);=0A=
 	if (ret !=3D NF_DROP && ret !=3D NF_STOLEN=0A=
-	    && daddr !=3D (*pskb)->nh.iph->daddr) {=0A=
+	    && ((*pskb)->nh.iph->saddr !=3D saddr=0A=
+	        || (*pskb)->nh.iph->daddr !=3D daddr)) {=0A=
 		dst_release((*pskb)->dst);=0A=
 		(*pskb)->dst =3D NULL;=0A=
 	}=0A=

------=_NextPart_000_0001_01C766E0.C8B63400--


