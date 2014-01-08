From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] net: xfrm: xfrm_policy: silence compiler warning
Date: Wed, 8 Jan 2014 10:26:39 +0800
Message-ID: <1389147999-15944-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54927 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994AbaAHC0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 21:26:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix below compiler warning:

net/xfrm/xfrm_policy.c:1644:12: warning: =E2=80=98xfrm_dst_alloc_copy=E2=
=80=99 defined but not used [-Wunused-function]

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/xfrm/xfrm_policy.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b390446..e205c4b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1641,6 +1641,7 @@ free_dst:
 	goto out;
 }
=20
+#ifdef CONFIG_XFRM_SUB_POLICY
 static int xfrm_dst_alloc_copy(void **target, const void *src, int siz=
e)
 {
 	if (!*target) {
@@ -1652,6 +1653,7 @@ static int xfrm_dst_alloc_copy(void **target, con=
st void *src, int size)
 	memcpy(*target, src, size);
 	return 0;
 }
+#endif
=20
 static int xfrm_dst_update_parent(struct dst_entry *dst,
 				  const struct xfrm_selector *sel)
--=20
1.7.9.5
