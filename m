From: "Leigh Brown" <leigh@solinno.co.uk>
Subject: [TCP]: Fix oops caused by tcp_v4_md5_do_del
Date: Sun, 17 Dec 2006 13:44:45 -0000 (GMT)
Message-ID: <45953.81.105.127.245.1166363085.squirrel@www.solinno.co.uk>
References: <45239.81.105.127.245.1165964614.squirrel@www.solinno.co.uk>
    <20061212.172935.106265967.davem@davemloft.net>
    <45575.81.105.127.245.1166053430.squirrel@www.solinno.co.uk>
    <20061213.162235.21925707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mwuml021.modern-world.net ([193.110.88.84]:3447 "EHLO
	mwuml021.modern-world.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612AbWLQNor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 08:44:47 -0500
In-Reply-To: <20061213.162235.21925707.davem@davemloft.net>
To: "David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

md5sig_info.alloced4 must be set to zero when freeing keys4, otherwise
it will not be alloc'd again when another key is added to the same
socket by tcp_v4_md5_do_add.

Signed-off-by: Leigh Brown <leigh@solinno.co.uk>

diff -uprN a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2006-12-17 09:51:21.000000000 +0000
+++ b/net/ipv4/tcp_ipv4.c	2006-12-17 10:05:54.000000000 +0000
@@ -929,6 +929,7 @@ int tcp_v4_md5_do_del(struct sock *sk, _
 			if (tp->md5sig_info->entries4 == 0) {
 				kfree(tp->md5sig_info->keys4);
 				tp->md5sig_info->keys4 = NULL;
+				tp->md5sig_info->alloced4 = 0;
 			} else if (tp->md5sig_info->entries4 != i) {
 				/* Need to do some manipulation */
 				memcpy(&tp->md5sig_info->keys4[i],

