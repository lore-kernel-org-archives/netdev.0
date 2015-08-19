From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH RESEND net-next] lwtunnel: Fix the sparse warnings in fib_encap_match
Date: Wed, 19 Aug 2015 15:46:17 +0800
Message-ID: <1439970377-13032-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <jbenc@redhat.com>,
	<fengguang.wu@intel.com>, <kbuild-all@01.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:56048 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814AbbHSHqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 03:46:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_LWTUNNEL config is not enabled, the lwtstate_free() is not
declared in lwtunnel.h at all. However, even in this case, the function
is still referenced in fib_semantics.c so that there appears the
following sparse warnings:

net/ipv4/fib_semantics.c:553:17: error: undefined identifier 'lwtstate_=
free'
  CC      net/ipv4/fib_semantics.o
  net/ipv4/fib_semantics.c: In function =E2=80=98fib_encap_match=E2=80=99=
:
  net/ipv4/fib_semantics.c:553:3: error: implicit declaration of functi=
on =E2=80=98lwtstate_free=E2=80=99 [-Werror=3Dimplicit-function-declara=
tion]
  cc1: some warnings being treated as errors
  make[1]: *** [net/ipv4/fib_semantics.o] Error 1
  make: *** [net/ipv4/fib_semantics.o] Error 2

To eliminate the error, we define an empty function for lwtstate_free()
in lwtunnel.h when CONFIG_LWTUNNEL is disabled.

=46ixes: df383e6240ef ("lwtunnel: fix memory leak")
Cc: Jiri Benc <jbenc@redhat.com>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/lwtunnel.h |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index 34fd8f7..cfee539 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -93,6 +93,10 @@ int lwtunnel_input6(struct sk_buff *skb);
=20
 #else
=20
+static inline void lwtstate_free(struct lwtunnel_state *lws)
+{
+}
+
 static inline struct lwtunnel_state *
 lwtstate_get(struct lwtunnel_state *lws)
 {
--=20
1.7.9.5
