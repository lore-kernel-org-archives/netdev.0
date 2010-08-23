From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iproute2: add 64bit support to ifstat
Date: Mon, 23 Aug 2010 21:44:56 +0200
Message-ID: <1282592696.2378.193.camel@edumazet-laptop>
References: <20100823083258.0777e83d@nehalam>
	 <1282578203.2267.27.camel@achroite.uk.solarflarecom.com>
	 <20100823091750.2bf87605@nehalam>
	 <1282582464.2486.479.camel@edumazet-laptop>
	 <20100823103333.67c5f795@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41826 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063Ab0HWTpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 15:45:06 -0400
Received: by bwz11 with SMTP id 11so4213955bwz.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 12:45:04 -0700 (PDT)
In-Reply-To: <20100823103333.67c5f795@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 23 ao=C3=BBt 2010 =C3=A0 10:33 -0700, Stephen Hemminger a =C3=A9=
crit :

> I think this breaks the wraparound detection code in this command.
>=20
>=20

OK lets fix the bug only, before adding 64bit counters capabilities.

Thanks

[PATCH] iproute2: add 64bit arches support to ifstat

ifstat assumes IFLA_STATS fields are "unsigned long", but they are
__u32. This fix is needed to let ifstat run on 64bit arches.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/misc/ifstat.c b/misc/ifstat.c
index 5cf2e01..5b229e7 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -49,7 +49,7 @@ int npatterns;
 char info_source[128];
 int source_mismatch;
=20
-#define MAXS (sizeof(struct rtnl_link_stats)/sizeof(unsigned long))
+#define MAXS (sizeof(struct rtnl_link_stats)/sizeof(__u32))
=20
 struct ifstat_ent
 {
@@ -58,7 +58,7 @@ struct ifstat_ent
 	int			ifindex;
 	unsigned long long	val[MAXS];
 	double			rate[MAXS];
-	unsigned long		ival[MAXS];
+	__u32			ival[MAXS];
 };
=20
 struct ifstat_ent *kern_db;
@@ -187,7 +187,7 @@ void load_raw_table(FILE *fp)
 			*next++ =3D 0;
 			if (sscanf(p, "%llu", n->val+i) !=3D 1)
 				abort();
-			n->ival[i] =3D (unsigned long)n->val[i];
+			n->ival[i] =3D (__u32)n->val[i];
 			p =3D next;
 			if (!(next =3D strchr(p, ' ')))
 				abort();
@@ -563,8 +563,6 @@ static void usage(void)
 "   -s, --noupdate	don;t update history\n"
 "   -t, --interval=3DSECS	report average over the last SECS\n"
 "   -V, --version	output version information\n"
-"   -z, --zeros		show entries with zero activity\n"
-"   -e, --errors	show errors\n"
 "   -z, --zeros		show entries with zero activity\n");
=20
 	exit(-1);
@@ -581,8 +579,6 @@ static const struct option longopts[] =3D {
 	{ "interval", 1, 0, 't' },
 	{ "version", 0, 0, 'V' },
 	{ "zeros", 0, 0, 'z' },
-	{ "errors", 0, 0, 'e' },
-	{ "zeros", 0, 0, 'z' },
 	{ 0 }
 };
=20


