From: =?utf-8?B?Iklnb3IgTWFyYXZpxIci?= <igorm@etf.rs>
Subject: [PATCH] cls_rsvp.h was outdated
Date: Tue, 30 Aug 2011 15:12:55 +0200
Message-ID: <59e0c7c0ba5282f35b101e7058fb27fa.squirrel@kondor.etf.bg.ac.rs>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:38363 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045Ab1H3NM6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 09:12:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ile cls_rsvp.h in /net/sched was outdated. I'm sending you patch for=
 this
file.

Sorry for the word-wrap in previous messages

Signed-off-by: Igor Maravi=C4=87 <igorm@etf.rs>

---

--- linux-2.6.38.8/net/sched/cls_rsvp.h.orig	2011-08-30 12:46:42.663443=
918 +0200
+++ linux-2.6.38.8/net/sched/cls_rsvp.h	2011-08-30 13:45:02.135445119 +=
0200
@@ -425,7 +425,7 @@ static int rsvp_change(struct tcf_proto
 	struct rsvp_filter *f, **fp;
 	struct rsvp_session *s, **sp;
 	struct tc_rsvp_pinfo *pinfo =3D NULL;
-	struct nlattr *opt =3D tca[TCA_OPTIONS-1];
+	struct nlattr *opt =3D tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_RSVP_MAX + 1];
 	struct tcf_exts e;
 	unsigned h1, h2;
@@ -439,7 +439,7 @@ static int rsvp_change(struct tcf_proto
 	if (err < 0)
 		return err;

-	err =3D tcf_exts_validate(tp, tb, tca[TCA_RATE-1], &e, &rsvp_ext_map)=
;
+	err =3D tcf_exts_validate(tp, tb, tca[TCA_RATE], &e, &rsvp_ext_map);
 	if (err < 0)
 		return err;

@@ -448,8 +448,8 @@ static int rsvp_change(struct tcf_proto

 		if (f->handle !=3D handle && handle)
 			goto errout2;
-		if (tb[TCA_RSVP_CLASSID-1]) {
-			f->res.classid =3D nla_get_u32(tb[TCA_RSVP_CLASSID-1]);
+		if (tb[TCA_RSVP_CLASSID]) {
+			f->res.classid =3D nla_get_u32(tb[TCA_RSVP_CLASSID]);
 			tcf_bind_filter(tp, &f->res, base);
 		}

@@ -461,7 +461,7 @@ static int rsvp_change(struct tcf_proto
 	err =3D -EINVAL;
 	if (handle)
 		goto errout2;
-	if (tb[TCA_RSVP_DST-1] =3D=3D NULL)
+	if (tb[TCA_RSVP_DST] =3D=3D NULL)
 		goto errout2;

 	err =3D -ENOBUFS;
@@ -470,19 +470,19 @@ static int rsvp_change(struct tcf_proto
 		goto errout2;

 	h2 =3D 16;
-	if (tb[TCA_RSVP_SRC-1]) {
-		memcpy(f->src, nla_data(tb[TCA_RSVP_SRC-1]), sizeof(f->src));
+	if (tb[TCA_RSVP_SRC]) {
+		memcpy(f->src, nla_data(tb[TCA_RSVP_SRC]), sizeof(f->src));
 		h2 =3D hash_src(f->src);
 	}
-	if (tb[TCA_RSVP_PINFO-1]) {
-		pinfo =3D nla_data(tb[TCA_RSVP_PINFO-1]);
+	if (tb[TCA_RSVP_PINFO]) {
+		pinfo =3D nla_data(tb[TCA_RSVP_PINFO]);
 		f->spi =3D pinfo->spi;
 		f->tunnelhdr =3D pinfo->tunnelhdr;
 	}
-	if (tb[TCA_RSVP_CLASSID-1])
-		f->res.classid =3D nla_get_u32(tb[TCA_RSVP_CLASSID-1]);
+	if (tb[TCA_RSVP_CLASSID])
+		f->res.classid =3D nla_get_u32(tb[TCA_RSVP_CLASSID]);

-	dst =3D nla_data(tb[TCA_RSVP_DST-1]);
+	dst =3D nla_data(tb[TCA_RSVP_DST]);
 	h1 =3D hash_dst(dst, pinfo ? pinfo->protocol : 0, pinfo ? pinfo->tunn=
elid : 0);

 	err =3D -ENOMEM;
@@ -641,8 +641,7 @@ nla_put_failure:
 	return -1;
 }

-static struct tcf_proto_ops RSVP_OPS =3D {
-	.next		=3D	NULL,
+static struct tcf_proto_ops RSVP_OPS __read_mostly =3D {
 	.kind		=3D	RSVP_ID,
 	.classify	=3D	rsvp_classify,
 	.init		=3D	rsvp_init,
