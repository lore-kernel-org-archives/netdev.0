From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v6 2/7 RFC] TCPCT part 1b: generate Responder
 Cookie
Date: Fri, 13 Nov 2009 07:21:04 +0100
Message-ID: <4AFCFAD0.4010701@gmail.com>
References: <4AFCDA9E.8050003@gmail.com> <4AFCDDC4.1090606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40838 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765AbZKMGVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 01:21:01 -0500
In-Reply-To: <4AFCDDC4.1090606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> Define (missing) hash message size for SHA1.
>=20
> Define hashing size constants specific to TCP cookies, and add new
> function.
>=20
> Maintain global secret values for tcp_cookie_generator().
>=20
> This is a significantly revised implementation of earlier (15-year-ol=
d)
> Photuris [RFC-2522] code for the KA9Q cooperative multitasking platfo=
rm.
>=20
> Linux RCU technique appears to be well-suited to this application, th=
ough
> neither of the circular queue items are freed.
>=20
> These functions will also be used in subsequent patches that implemen=
t
> additional features.
>=20
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>  include/linux/cryptohash.h |    1 +
>  include/net/tcp.h          |    8 +++
>  net/ipv4/tcp.c             |  146
> ++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 155 insertions(+), 0 deletions(-)
>=20

Small point :

+	if (unlikely(time_after_eq(jiffy, tcp_secret_generating->expires))) {
+		spin_lock_bh(&tcp_secret_locker);
+		if (!time_after_eq(jiffy, tcp_secret_generating->expires)) {
+			/* refreshed by another */
+			spin_unlock_bh(&tcp_secret_locker);
+			memcpy(bakery,
+			       &tcp_secret_generating->secrets[0],
+			       sizeof(tcp_secret_generating->secrets));

Technically speaking, you should perform the memcpy() before spin_unloc=
k_bh()

+	if (unlikely(time_after_eq(jiffy, tcp_secret_generating->expires))) {
+		spin_lock_bh(&tcp_secret_locker);
+		if (!time_after_eq(jiffy, tcp_secret_generating->expires)) {
+			/* refreshed by another */
+			memcpy(bakery,
+			       &tcp_secret_generating->secrets[0],
+			       sizeof(tcp_secret_generating->secrets));
+			spin_unlock_bh(&tcp_secret_locker);

