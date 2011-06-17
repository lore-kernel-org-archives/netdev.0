From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: what's causing "ip_rt_bug"?
Date: Fri, 17 Jun 2011 22:36:33 +0200
Message-ID: <1308342993.3539.30.camel@edumazet-laptop>
References: <4DFBB270.8000003@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tomasz Chmielewski <mangoo@wpkg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61318 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932321Ab1FQUgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 16:36:37 -0400
Received: by wyb38 with SMTP id 38so562828wyb.19
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 13:36:36 -0700 (PDT)
In-Reply-To: <4DFBB270.8000003@wpkg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 juin 2011 =C3=A0 22:00 +0200, Tomasz Chmielewski a =C3=A9=
crit :
> I have a system pushing around 800 Mbit/s, ~130 kpps.
>=20
> It uses 2.6.35.12 kernel.
>=20
>=20
> Several times a minute, I can see entries like (a.b.c.d - IP of this =
system):
>=20
> Jun 18 02:39:19 KOR-SV22 kernel: [37187.665951] ip_rt_bug: 110.x.x.x =
-> a.b.c.d, ?
> Jun 18 02:39:19 KOR-SV22 kernel: [37187.685419] ip_rt_bug: 110.x.x.x =
-> a.b.c.d, ?
> Jun 18 02:40:31 KOR-SV22 kernel: [37259.199315] ip_rt_bug: 124.x.x.x =
-> a.b.c.d, ?
> Jun 18 02:40:36 KOR-SV22 kernel: [37263.828000] ip_rt_bug: 124.x.x.x =
-> a.b.c.d, ?
> Jun 18 02:44:16 KOR-SV22 kernel: [37484.120689] ip_rt_bug: 110.x.x.x =
-> a.b.c.d, ?
> Jun 18 02:44:19 KOR-SV22 kernel: [37487.114357] ip_rt_bug: 110.x.x.x =
-> a.b.c.d, ?
>=20

Hi

What your routing table looks like ? (ip ro)

You also could backport this patch so that we can catch where/why this
happens

commit c378a9c019cf5e017d1ed24954b54fae7bebd2bc
Author: Dave Jones <davej@redhat.com>
Date:   Sat May 21 07:16:42 2011 +0000

    ipv4: Give backtrace in ip_rt_bug().
   =20
    Add a stack backtrace to the ip_rt_bug path for debugging
   =20
    Signed-off-by: Dave Jones <davej@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b24d58e..52b0b95 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1665,6 +1665,7 @@ static int ip_rt_bug(struct sk_buff *skb)
 		&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr,
 		skb->dev ? skb->dev->name : "?");
 	kfree_skb(skb);
+	WARN_ON(1);
 	return 0;
 }
=20



