From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>
Subject: [PATCH net] ematch: Fix matching of inverted containers.
Date: Wed, 24 Sep 2014 18:38:39 +0200
Message-ID: <20140924163839.GA6925@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:50821 "EHLO qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754386AbaIXRU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 13:20:57 -0400
Received: from zenon.in.qult.net ([192.168.64.1])
	by qult.net with esmtpsa (TLS1.2:DHE_RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1XWpaS-0005pX-SG
	for netdev@vger.kernel.org; Wed, 24 Sep 2014 18:38:40 +0200
Received: from ig by zenon.in.qult.net with local (Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1XWpaR-0001uu-U8
	for netdev@vger.kernel.org; Wed, 24 Sep 2014 18:38:39 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Negated expressions and sub-expressions need to have their flags checke=
d for
TCF_EM_INVERT and their result negated accordingly.

Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.=
fr>
---
 net/sched/ematch.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index 3a633de..ad57f44 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -526,9 +526,11 @@ pop_stack:
 		match_idx =3D stack[--stackp];
 		cur_match =3D tcf_em_get_match(tree, match_idx);
=20
-		if (tcf_em_early_end(cur_match, res))
+		if (tcf_em_early_end(cur_match, res)) {
+			if (tcf_em_is_inverted(cur_match))
+				res =3D !res;
 			goto pop_stack;
-		else {
+		} else {
 			match_idx++;
 			goto proceed;
 		}
--=20
1.9.1
