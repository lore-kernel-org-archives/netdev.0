From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/07: snmp nat leaks memory in case of failure
Date: Mon, 20 Oct 2008 11:54:13 +0200 (MEST)
Message-ID: <20081020095413.25670.77921.sendpatchset@x2.localnet>
References: <20081020095408.25670.37455.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52351 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbYJTJyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 05:54:14 -0400
In-Reply-To: <20081020095408.25670.37455.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f935265f6041e490715ec31c7f918b8c348b5b95
Author: \"Ilpo Jarvinen\ <ilpo.jarvinen@helsinki.fi>
Date:   Sat Oct 18 15:20:56 2008 +0200

    netfilter: snmp nat leaks memory in case of failure
   =20
    Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilte=
r/nf_nat_snmp_basic.c
index ffeaffc..8303e4b 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -742,6 +742,7 @@ static unsigned char snmp_object_decode(struct asn1=
_ctx *ctx,
 			*obj =3D kmalloc(sizeof(struct snmp_object) + len,
 				       GFP_ATOMIC);
 			if (*obj =3D=3D NULL) {
+				kfree(p);
 				kfree(id);
 				if (net_ratelimit())
 					printk("OOM in bsalg (%d)\n", __LINE__);
