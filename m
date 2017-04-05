From: hiren panchasara <hiren@strugglingcoder.info>
Subject: tcpprobe display format for snd_nxt and snd_una
Date: Wed, 5 Apr 2017 12:40:09 -0700
Message-ID: <20170405194009.GH62406@strugglingcoder.info>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="Z8yxTSU1mh2gsre7"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from strugglingcoder.info ([104.236.146.68]:51239 "EHLO
        mail.strugglingcoder.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753393AbdDETph (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 15:45:37 -0400
Received: from localhost (unknown [10.1.1.3])
        (Authenticated sender: hiren@strugglingcoder.info)
        by mail.strugglingcoder.info (Postfix) with ESMTPA id 3504C17EF9
        for <netdev@vger.kernel.org>; Wed,  5 Apr 2017 12:40:09 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Z8yxTSU1mh2gsre7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

(New to linux and first-time poster so please guide me if needed.)
=20
Upon using tcpprobe I realized that it prints snd_nxt and snd_una as hex
which makes it harder to read and compare with tcpdump for example.
=20
Not sure if that is intentional. If not, a simple patch like this would
print them as decimals.
=20
[PATCH] Display snd_nxt and snd_una as decimals for better
 readability.
=20
---
 net/ipv4/tcp_probe.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
=20
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index f6c50af..a8e66c1 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -191,7 +191,7 @@ static int tcpprobe_sprint(char *tbuf, int n)
                =3D ktime_to_timespec64(ktime_sub(p->tstamp, tcp_probe.star=
t));
=20
        return scnprintf(tbuf, n,
-                       "%lu.%09lu %pISpc %pISpc %d %#x %#x %u %u %u %u %u\=
n",
+                       "%lu.%09lu %pISpc %pISpc %d %u %u %u %u %u %u %u\n",
                        (unsigned long)ts.tv_sec,
                        (unsigned long)ts.tv_nsec,
                        &p->src, &p->dst, p->length, p->snd_nxt, p->snd_una,
--Z8yxTSU1mh2gsre7--
