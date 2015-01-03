From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/2 net-next] netfilter: remove err1 label only used with CONFIG_SYSCTL
Date: Sat,  3 Jan 2015 12:42:08 +0100
Message-ID: <1420285328-7901-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fabian Frederick <fabf@skynet.be>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay011.isp.belgacom.be ([195.238.6.178]:22397 "EHLO
	mailrelay011.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750966AbbACLmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2015 06:42:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following warning:
net/bridge/br_netfilter.c:995:1: warning: label =E2=80=98err1=E2=80=99 =
defined but not used [-Wunused-label]

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/bridge/br_netfilter.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index c190d22..37e7d9a 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -987,15 +987,12 @@ static int __init br_netfilter_init(void)
 	if (brnf_sysctl_header =3D=3D NULL) {
 		printk(KERN_WARNING
 		       "br_netfilter: can't register to sysctl.\n");
-		ret =3D -ENOMEM;
-		goto err1;
+		nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+		return -ENOMEM;
 	}
 #endif
 	printk(KERN_NOTICE "Bridge firewalling registered\n");
 	return 0;
-err1:
-	nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
-	return ret;
 }
=20
 static void __exit br_netfilter_fini(void)
--=20
2.1.0
