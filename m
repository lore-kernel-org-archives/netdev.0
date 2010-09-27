From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] sunrpc: prompt for RPCSEC_GSS_KRB5 even if NFS_V4 is enabled
Date: Mon, 27 Sep 2010 12:41:59 +0200
Message-ID: <1285584120-16860-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20100909181454.GB14915@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100909181454.GB14915@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NFS_V4 works fine without RPCSEC_GSS_KRB5 (even without CRYPTO).
This dependency was introduced in

	df486a2 (NFS: Fix the selection of security flavours in Kconfig)

to fix a build failure as RPCSEC_GSS_KRB5 was thought to be needed for
NFS_V4.  The fix didn't work completely as NFS_V4 didn't enforce CRYPTO
and so the select on RPCSEC_GSS_KRB5 didn't work in all situations (e.g=
=2E
arm/mx1_defconfig).

This was rectified by

	827e345 (SUNRPC: Fix the NFSv4 and RPCSEC_GSS Kconfig dependencies)

but the magic for RPCSEC_GSS_KRB5 introduced by df486a2 wasn't reverted=
=2E

Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
Hello,

after Trond sent me the patch that later ended in 827e345702 I suggeste=
d
to fold the patch below into it[1], but without reaction and success as=
 I
noticed just now. :-(

Best regards
Uwe

[1] http://thread.gmane.org/gmane.linux.kernel/1027380/focus=3D1033847

 net/sunrpc/Kconfig |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 3376d76..442efe1 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -20,8 +20,7 @@ config SUNRPC_XPRT_RDMA
 config RPCSEC_GSS_KRB5
 	tristate
 	depends on SUNRPC && CRYPTO
-	prompt "Secure RPC: Kerberos V mechanism" if !(NFS_V4 || NFSD_V4)
-	default y
+	prompt "Secure RPC: Kerberos V mechanism"
 	select SUNRPC_GSS
 	select CRYPTO_MD5
 	select CRYPTO_DES
--=20
1.7.2.3
