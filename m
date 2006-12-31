From: "=?ISO-8859-1?Q?Daniel_Marjam=E4ki?=" <daniel.marjamaki@gmail.com>
Subject: [PATCH] net/core/flow.c: compare data with memcmp
Date: Sun, 31 Dec 2006 17:37:05 +0100
Message-ID: <80ec54e90612310837y786fd764oc18bf37c8f0b2b8c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel-janitors@lists.osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:5706 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933193AbWLaQhG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Dec 2006 11:37:06 -0500
Received: by nf-out-0910.google.com with SMTP id o25so6664245nfa
        for <netdev@vger.kernel.org>; Sun, 31 Dec 2006 08:37:05 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Daniel Marjam=E4ki
This has been tested by me.
Signed-off-by: Daniel Marjam=E4ki <daniel.marjamaki@gmail.com>
--- linux-2.6.20-rc2/net/core/flow.c	2006-12-27 09:59:56.000000000 +010=
0
+++ linux/net/core/flow.c	2006-12-31 18:26:06.000000000 +0100
@@ -144,29 +144,16 @@ typedef u32 flow_compare_t;

 extern void flowi_is_missized(void);

-/* I hear what you're saying, use memcmp.  But memcmp cannot make
- * important assumptions that we can here, such as alignment and
- * constant size.
- */
 static int flow_key_compare(struct flowi *key1, struct flowi *key2)
 {
-	flow_compare_t *k1, *k1_lim, *k2;
-	const int n_elem =3D sizeof(struct flowi) / sizeof(flow_compare_t);
-
 	if (sizeof(struct flowi) % sizeof(flow_compare_t))
 		flowi_is_missized();

-	k1 =3D (flow_compare_t *) key1;
-	k1_lim =3D k1 + n_elem;
-
-	k2 =3D (flow_compare_t *) key2;
-
-	do {
-		if (*k1++ !=3D *k2++)
-			return 1;
-	} while (k1 < k1_lim);
+	/* Number of elements to compare */
+	const int n_elem =3D sizeof(struct flowi) / sizeof(flow_compare_t);

-	return 0;
+	/* Compare all elements in key1 and key2. */
+	return memcmp(key1, key2, n_elem * sizeof(flow_compare_t));
 }

 void *flow_cache_lookup(struct flowi *key, u16 family, u8 dir,
