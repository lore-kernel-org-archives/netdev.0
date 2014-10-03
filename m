From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>
Subject: [PATCH net] ematch: Fix the matching of inverted containers (again).
Date: Fri, 3 Oct 2014 10:06:00 +0200
Message-ID: <20141003080600.GA13146@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:54237 "EHLO qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750814AbaJCIG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 04:06:28 -0400
Received: from zenon.in.qult.net ([192.168.64.1])
	by qult.net with esmtpsa (TLS1.2:DHE_RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1XZxsH-0007ol-NO
	for netdev@vger.kernel.org; Fri, 03 Oct 2014 10:06:01 +0200
Received: from ig by zenon.in.qult.net with local (Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1XZxsG-0003Rs-Lg
	for netdev@vger.kernel.org; Fri, 03 Oct 2014 10:06:00 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The result of a negated container has to be inverted before checking fo=
r
early ending.

Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.=
fr>
---
 net/sched/ematch.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index ad57f44..300ecf6 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -526,11 +526,12 @@ pop_stack:
 		match_idx =3D stack[--stackp];
 		cur_match =3D tcf_em_get_match(tree, match_idx);
=20
-		if (tcf_em_early_end(cur_match, res)) {
-			if (tcf_em_is_inverted(cur_match))
-				res =3D !res;
+		if (tcf_em_is_inverted(cur_match))
+			res =3D !res;
+
+		if (tcf_em_early_end(cur_match, res))
 			goto pop_stack;
-		} else {
+		else {
 			match_idx++;
 			goto proceed;
 		}
--=20
1.9.1
