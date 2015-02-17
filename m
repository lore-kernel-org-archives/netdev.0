From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>
Subject: [PATCH net v2] ematch: Fix auto-loading of ematch modules.
Date: Tue, 17 Feb 2015 20:15:20 +0100
Message-ID: <20150217191520.GA15405@zenon.in.qult.net>
References: <CAHA+R7Os10B8KuBV0K9qp48zo2+=_aXUR-k5ocXjEWYqtq222w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:33795 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752692AbbBQTQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Feb 2015 14:16:10 -0500
Received: from zenon.in.qult.net ([192.168.64.1] helo=zenon)
	by mail.qult.net with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YNncZ-0001XJ-0F
	for netdev@vger.kernel.org; Tue, 17 Feb 2015 20:15:47 +0100
Received: from ig by zenon with local (Exim 4.84_RC1)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YNnc8-00040p-6t
	for netdev@vger.kernel.org; Tue, 17 Feb 2015 20:15:20 +0100
Content-Disposition: inline
In-Reply-To: <CAHA+R7Os10B8KuBV0K9qp48zo2+=_aXUR-k5ocXjEWYqtq222w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tcf_em_validate(), after calling request_module() to load the
kind-specific module, set em->ops to NULL before returning -EAGAIN, so
that module_put() is not called again by tcf_em_tree_destroy().

Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.=
fr>
---
 net/sched/ematch.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index 6742200..fbb7ebf 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -228,6 +228,7 @@ static int tcf_em_validate(struct tcf_proto *tp,
 				 * to replay the request.
 				 */
 				module_put(em->ops->owner);
+				em->ops =3D NULL;
 				err =3D -EAGAIN;
 			}
 #endif
--=20
2.1.0
