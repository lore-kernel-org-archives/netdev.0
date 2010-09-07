From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: introduce rcu_dereference_rtnl
Date: Tue, 07 Sep 2010 23:07:37 +0200
Message-ID: <1283893657.2634.210.camel@edumazet-laptop>
References: <1283890291.2634.143.camel@edumazet-laptop>
	 <4C86A558.6030802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34717 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216Ab0IGVHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 17:07:48 -0400
Received: by fxm16 with SMTP id 16so312725fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 14:07:47 -0700 (PDT)
In-Reply-To: <4C86A558.6030802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 22:49 +0200, Jarek Poplawski a =C3=A9=
crit :
> Eric Dumazet wrote, On 09/07/2010 10:11 PM:
>=20
> > We use rcu_dereference_check(p, rcu_read_lock_held() ||
> > lockdep_rtnl_is_held()) several times in network stack.
> >=20
> > More usages to come too, so its time to create a helper.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> > include/linux/rtnetlink.h |   12 ++++++++++++
> >=20
> > diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> > index 58d4449..5ba48bb 100644
> > --- a/include/linux/rtnetlink.h
> > +++ b/include/linux/rtnetlink.h
> > @@ -745,10 +745,22 @@ extern void rtnl_lock(void);
> >  extern void rtnl_unlock(void);
> >  extern int rtnl_trylock(void);
> >  extern int rtnl_is_locked(void);
> > +
> >  #ifdef CONFIG_PROVE_LOCKING
> >  extern int lockdep_rtnl_is_held(void);
> >  #endif /* #ifdef CONFIG_PROVE_LOCKING */
> > =20
> > +/**
> > + * rcu_dereference_read_lock_or_rtnl - rcu_dereference with debug =
checking
> > + * @p: The pointer to read, prior to dereferencing
> > + *
> > + * Do an rcu_dereference(p), but check caller either holds rcu_rea=
d_lock()
> > + * or RTNL
> > + */
> > +#define rcu_dereference_read_lock_or_rtnl(p)
>=20
>=20
> My proposal is to shorten the name, and since rcu_read_lock
> part seems obvious, maybe rcu_dereference_rtnl() only?

Yes, name is absolutely awful, I am very bad at this kind of games :)

Thanks !

[PATCH net-next-2.6] net: introduce rcu_dereference_rtnl

We use rcu_dereference_check(p, rcu_read_lock_held() ||
lockdep_rtnl_is_held()) several times in network stack.

More usages to come too, so its time to create a helper.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/rtnetlink.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 58d4449..057a08f 100644
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
+				 lockdep_rtnl_is_held());
+
 extern void rtnetlink_init(void);
 extern void __rtnl_unlock(void);
=20


