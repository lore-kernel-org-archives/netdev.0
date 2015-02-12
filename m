From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] bridge: netfilter: Move sysctl-specific error code inside #ifdef
Date: Thu, 12 Feb 2015 15:17:27 +0100
Message-ID: <1423750647-30389-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If CONFIG_SYSCTL=3Dn:

    net/bridge/br_netfilter.c: In function =E2=80=98br_netfilter_init=E2=
=80=99:
    net/bridge/br_netfilter.c:996: warning: label =E2=80=98err1=E2=80=99=
 defined but not used

Move the label and the code after it inside the existing #ifdef to get
rid of the warning.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 net/bridge/br_netfilter.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 65728e0dc4ffd011..0ee453fad3de6521 100644
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
1.9.1
