From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>
Subject: [PATCH net v2 1/1] ematch: Fix early ending of inverted containers.
Date: Fri, 3 Oct 2014 15:44:48 +0200
Message-ID: <20141003134448.GB26399@zenon.in.qult.net>
References: <542E9505.8010805@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:55167 "EHLO qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752528AbaJCNpQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 09:45:16 -0400
Received: from zenon.in.qult.net ([192.168.64.1])
	by qult.net with esmtpsa (TLS1.2:DHE_RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1Xa3A8-0000V2-Pj
	for netdev@vger.kernel.org; Fri, 03 Oct 2014 15:44:48 +0200
Received: from ig by zenon.in.qult.net with local (Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1Xa3A8-0007GX-5c
	for netdev@vger.kernel.org; Fri, 03 Oct 2014 15:44:48 +0200
Content-Disposition: inline
In-Reply-To: <542E9505.8010805@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The result of a negated container has to be inverted before checking fo=
r
early ending.

This fixes my previous attempt (17c9c8232663a47f074b7452b9b034efda868ca=
7) to
make inverted containers work correctly.

Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.=
fr>
---
 net/sched/ematch.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index ad57f44..f878fa1 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -526,9 +526,10 @@ pop_stack:
 		match_idx =3D stack[--stackp];
 		cur_match =3D tcf_em_get_match(tree, match_idx);
=20
+		if (tcf_em_is_inverted(cur_match))
+			res =3D !res;
+
 		if (tcf_em_early_end(cur_match, res)) {
-			if (tcf_em_is_inverted(cur_match))
-				res =3D !res;
 			goto pop_stack;
 		} else {
 			match_idx++;
--=20
1.9.1
