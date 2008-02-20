From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 5/8] [NET]: uninline dst_release
Date: Wed, 20 Feb 2008 15:47:15 +0200
Message-ID: <1203515238-22848-6-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47679 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486AbYBTNrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 08:47:22 -0500
In-Reply-To: <1203515238-22848-5-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Codiff stats:
-16420  187 funcs, 103 +, 16523 -, diff: -16420 --- dst_release

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/dst.h |   10 +---------
 net/core/dst.c    |   10 ++++++++++
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index e3ac7d0..bf33471 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -158,15 +158,7 @@ struct dst_entry * dst_clone(struct dst_entry * ds=
t)
 	return dst;
 }
=20
-static inline
-void dst_release(struct dst_entry * dst)
-{
-	if (dst) {
-		WARN_ON(atomic_read(&dst->__refcnt) < 1);
-		smp_mb__before_atomic_dec();
-		atomic_dec(&dst->__refcnt);
-	}
-}
+extern void dst_release(struct dst_entry *dst);
=20
 /* Children define the path of the packet through the
  * Linux networking.  Thus, destinations are stackable.
diff --git a/net/core/dst.c b/net/core/dst.c
index 7deef48..cc2e724 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -259,6 +259,16 @@ again:
 	return NULL;
 }
=20
+void dst_release(struct dst_entry *dst)
+{
+	if (dst) {
+		WARN_ON(atomic_read(&dst->__refcnt) < 1);
+		smp_mb__before_atomic_dec();
+		atomic_dec(&dst->__refcnt);
+	}
+}
+EXPORT_SYMBOL(dst_release);
+
 /* Dirty hack. We did it in 2.2 (in __dst_free),
  * we have _very_ good reasons not to repeat
  * this mistake in 2.3, but we have no choice
--=20
1.5.2.2

