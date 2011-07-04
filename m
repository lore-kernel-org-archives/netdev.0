From: Esa-Pekka Pyokkimies <esa-pekka.pyokkimies@stonesoft.com>
Subject: [PATCH] net/core: Make urgent data inline by default
Date: Mon, 4 Jul 2011 15:51:06 +0300
Message-ID: <op.vx3hzgtw6ywr33@esapekka-pc.rad1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hki-smtp-1b.stonesoft.com ([84.34.144.100]:37485 "EHLO
	hki-smtp-1b.stonesoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755468Ab1GDMvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 08:51:14 -0400
Received: from hki-smtp-1b.stonesoft.com (localhost.localdomain [127.0.0.1])
	by localhost.stonesoft.com (Postfix) with ESMTP id 31F1339F0130
	for <netdev@vger.kernel.org>; Mon,  4 Jul 2011 15:51:09 +0300 (EEST)
Received: from outlook.stonesoft.com (unknown [172.16.40.21])
	(using TLSv1 with cipher AES128-SHA (128/128 bits))
	(No client certificate requested)
	by hki-smtp-1b.stonesoft.com (Postfix) with ESMTP id 0BD9239F012C
	for <netdev@vger.kernel.org>; Mon,  4 Jul 2011 15:51:09 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make urgent data inline by default. As explained in RFC 6093, urgent
data should never be handled out-of-band.

"The TCP urgent mechanism is NOT a mechanism for sending "out-of-band"
  data: the so-called "urgent data" should be delivered "in-line" to
  the TCP user."

Signed-off-by: Esa-Pekka Pyokkimies <esa-pekka.pyokkimies@stonesoft.com>

---
  net/core/sock.c |    1 +
  1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 6e81978..83234bd 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1985,6 +1985,7 @@ void sock_init_data(struct socket *sock, struct sock  
*sk)
         sk_set_socket(sk, sock);

         sock_set_flag(sk, SOCK_ZAPPED);
+	sock_set_flag(sk, SOCK_URGINLINE);

         if (sock) {
                 sk->sk_type     =       sock->type;
