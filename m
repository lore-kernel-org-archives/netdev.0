From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] Implement IP_UNICAST_IF socket option.
Date: Fri, 03 Feb 2012 11:01:18 +0100
Message-ID: <1328263278.2157.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328218567-3134-1-git-send-email-ehoover@mines.edu>
	 <1328219828.2480.32.camel@edumazet-laptop>
	 <CAEU2+vrgxzTmiHWs-kVoKeu2_DcFZQBjCXwQfQ8dms5O6+Larg@mail.gmail.com>
	 <1328222744.2480.38.camel@edumazet-laptop>
	 <CAEU2+vrtwSUKgY1f44h8btcKnhvhBHUU-d_BkkyYx+E1KViQ+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:61659 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755191Ab2BCKBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 05:01:23 -0500
Received: by werb13 with SMTP id b13so2539652wer.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 02:01:22 -0800 (PST)
In-Reply-To: <CAEU2+vrtwSUKgY1f44h8btcKnhvhBHUU-d_BkkyYx+E1KViQ+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 18:22 -0700, Erich E. Hoover a =C3=
=A9crit :

> I though I should double check this, and apparently I missed that
> there's an equivalent IPV6_UNICAST_IF on "other OS".  Should that be =
a
> patch 2 or should it be included in this one?

Do as you prefer.

BTW, do we really want the htonl() thing, and force device indexes in
2^24 range ? This seems odd anyway.

If yes, following patch is needed :

diff --git a/net/core/dev.c b/net/core/dev.c
index f124947..ce7ebde 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5193,7 +5193,10 @@ static int dev_new_index(struct net *net)
 {
 	static int ifindex;
 	for (;;) {
-		if (++ifindex <=3D 0)
+		/* Because of IP_UNICAST_IF support, we must limit indexes
+		 * to 24 bits. Zero value is also reserved.
+		 */
+		if (++ifindex >=3D (1<<24))
 			ifindex =3D 1;
 		if (!__dev_get_by_index(net, ifindex))
 			return ifindex;
