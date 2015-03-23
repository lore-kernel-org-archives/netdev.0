From: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: [PATCH net-next] net: Move the comment about unsettable socket-level
 options to default clause and update its reference.
Date: Mon, 23 Mar 2015 18:04:13 +0900
Message-ID: <550FD70D.9080500@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, hideaki.yoshifuji@miraclelinux.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og119.obsmtp.com ([64.18.2.16]:41895 "HELO
	exprod7og119.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751873AbbCWJER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 05:04:17 -0400
Received: by mail-pa0-f44.google.com with SMTP id we9so184874878pac.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 02:04:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We implement the SO_SNDLOWAT etc not to be settable and return
ENOPROTOOPT per 1003.1g 7.  Move the comment to appropriate
position and update the reference.

Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/core/sock.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index d9f9e48..01a4ebb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -928,8 +928,6 @@ set_rcvbuf:
 			sk->sk_mark = val;
 		break;
 
-		/* We implement the SO_SNDLOWAT etc to
-		   not be settable (1003.1g 5.3) */
 	case SO_RXQ_OVFL:
 		sock_valbool_flag(sk, SOCK_RXQ_OVFL, valbool);
 		break;
@@ -1234,6 +1232,9 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	default:
+		/* We implement the SO_SNDLOWAT etc to not be settable
+		 * (1003.1g 7).
+		 */
 		return -ENOPROTOOPT;
 	}
 
-- 
1.9.1
