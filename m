From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: introduce rcu_dereference_rtnl
Date: Wed, 08 Sep 2010 20:44:29 +0200
Message-ID: <1283971469.2428.9.camel@edumazet-laptop>
References: <1283890291.2634.143.camel@edumazet-laptop>
	 <4C86A558.6030802@gmail.com>  <1283893657.2634.210.camel@edumazet-laptop>
	 <1283970567.2237.0.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58952 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122Ab0IHSoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 14:44:34 -0400
Received: by fxm16 with SMTP id 16so344283fxm.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 11:44:33 -0700 (PDT)
In-Reply-To: <1283970567.2237.0.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 septembre 2010 =C3=A0 19:29 +0100, Ben Hutchings a =C3=A9=
crit :

> No semicolon on the end, please.  The 'caller' will add that.

Oh definitely, thanks !

[PATCH net-next-2.6] net: introduce rcu_dereference_rtnl

We use rcu_dereference_check(p, rcu_read_lock_held() ||
lockdep_rtnl_is_held()) several times in network stack.

More usages to come too, so its time to create a helper.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/rtnetlink.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 58d4449..263690d 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -749,6 +749,17 @@ extern int rtnl_is_locked(void);
 extern int lockdep_rtnl_is_held(void);
 #endif /* #ifdef CONFIG_PROVE_LOCKING */
=20
+/**
+ * rcu_dereference_rtnl - rcu_dereference with debug checking
+ * @p: The pointer to read, prior to dereferencing
+ *
+ * Do an rcu_dereference(p), but check caller either holds rcu_read_lo=
ck()
+ * or RTNL
+ */
+#define rcu_dereference_rtnl(p)					\
+	rcu_dereference_check(p, rcu_read_lock_held() ||	\
+				 lockdep_rtnl_is_held())
+
 extern void rtnetlink_init(void);
 extern void __rtnl_unlock(void);
=20


