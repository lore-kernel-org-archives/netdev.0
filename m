From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16120] New: Oops: 0000 [#1] SMP, unable to
 handle kernel NULL pointer dereference at (null)
Date: Sat, 05 Jun 2010 11:17:06 +0200
Message-ID: <1275729426.5238.6.camel@edumazet-laptop>
References: <bug-16120-10286@https.bugzilla.kernel.org/>
	 <20100604161737.25c7940a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, alex.vizor@gmail.com,
	Patrick McHardy <kaber@trash.net>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:65468 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932626Ab0FEJRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 05:17:24 -0400
Received: by wwc33 with SMTP id 33so84139wwc.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 02:17:22 -0700 (PDT)
In-Reply-To: <20100604161737.25c7940a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 juin 2010 =C3=A0 16:17 -0700, Andrew Morton a =C3=A9crit=
 :
> (switched to email.  Please respond via emailed reply-to-all, not via=
 the
> bugzilla web interface).
>=20
> On Fri, 4 Jun 2010 09:25:58 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>=20
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D16120
> >=20
> >            Summary: Oops: 0000 [#1] SMP, unable to handle kernel NU=
LL
> >                     pointer dereference at (null)
> >            Product: Platform Specific/Hardware
> >            Version: 2.5
> >     Kernel Version: 2.6.35-rc1
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: x86-64
> >         AssignedTo: platform_x86_64@kernel-bugs.osdl.org
> >         ReportedBy: alex.vizor@gmail.com
> >         Regression: Yes
> >=20
> >=20
> > Created an attachment (id=3D26647)
> >  --> (https://bugzilla.kernel.org/attachment.cgi?id=3D26647) id)

> > 2.6.35-rc1 kernel log
> >=20
> > It happens randomly, almost a week I used 2.6.35-rc1 and don't have=
 any
> > problems. But since last day it happened twice.
> >=20
> > I attached kernel log, please inform me if I can help in investigat=
ion.
> >=20
>=20
> ip6mr_sk_done() oopsed.

Only thing I found a first glance is a typo but this should not be the
root of the problem.

[PATCH] ip6mr: fix a typo in ip6mr_for_each_table()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 073071f..89c0b07 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -120,7 +120,7 @@ static void mroute_clean_tables(struct mr6_table *m=
rt);
 static void ipmr_expire_process(unsigned long arg);
=20
 #ifdef CONFIG_IPV6_MROUTE_MULTIPLE_TABLES
-#define ip6mr_for_each_table(mrt, met) \
+#define ip6mr_for_each_table(mrt, net) \
 	list_for_each_entry_rcu(mrt, &net->ipv6.mr6_tables, list)
=20
 static struct mr6_table *ip6mr_get_table(struct net *net, u32 id)


