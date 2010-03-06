From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC v2 00/10] snet: Security for NETwork syscalls
Date: Sat, 06 Mar 2010 19:20:26 +0100
Message-ID: <m26359qplh.fsf@ssh.synack.fr>
References: <1267561394-13626-1-git-send-email-sam@synack.fr>
	<201003030156.o231udx1023055@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, nhorman@tuxdriver.com, root@localdomain.pl,
	linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201003030156.o231udx1023055@www262.sakura.ne.jp> (Tetsuo Handa's
	message of "Wed, 03 Mar 2010 10:56:39 +0900")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> Regarding [RFC v2 06/10] snet: introduce snet_hooks
> +                       if ((verdict = snet_ticket_check(&info)) != SNET_VERDICT_NONE)
>
> Please avoid assignment in "if" statement, as scripts/checkpatch.pl suggests.

Right, I should have run script/checkpatch.pl on this set of patches. I
won't miss it next time. 

Thanks Tetsuo.
sam

>From ea2234c07ea1bf76579ba127c8a8be6ab276515f Mon Sep 17 00:00:00 2001
From: Samir Bellabes <sam@synack.fr>
Date: Sat, 6 Mar 2010 17:49:22 +0100
Subject: [PATCH 3/3] snet: avoid assigment in if statement

Noticed by Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 security/snet/snet_hooks.c |   37 +++++++++++++++++++++++++------------
 1 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/security/snet/snet_hooks.c b/security/snet/snet_hooks.c
index 689babe..d9cf0b9 100644
--- a/security/snet/snet_hooks.c
+++ b/security/snet/snet_hooks.c
@@ -160,7 +160,8 @@ static int snet_socket_bind(struct socket *sock,
 			info.dst.u3.ip = inet->inet_daddr;
 			info.src.u.port = ntohs(a->sin_port);
 			/* check tickets */
-			if ((verdict = snet_ticket_check(&info)) != SNET_VERDICT_NONE)
+			verdict = snet_ticket_check(&info) ;
+			if (verdict != SNET_VERDICT_NONE)
 				goto out;
 			/* inserting verdict PENDING */
 			info.verdict_id = snet_verdict_insert();
@@ -173,7 +174,8 @@ static int snet_socket_bind(struct socket *sock,
 			       sizeof(info.dst.u3.ip6));
 			info.src.u.port = ntohs(a6->sin6_port);
 			/* check tickets */
-			if ((verdict = snet_ticket_check(&info)) != SNET_VERDICT_NONE)
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
 				goto out;
 			/* inserting verdict PENDING */
 			info.verdict_id = snet_verdict_insert();
@@ -229,7 +231,8 @@ static int snet_socket_connect(struct socket *sock,
 			info.dst.u3.ip = a->sin_addr.s_addr;
 			info.dst.u.port = ntohs(a->sin_port);
 			/* check tickets */
-			if ((verdict = snet_ticket_check(&info)) != SNET_VERDICT_NONE)
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
 				goto out;
 			/* inserting verdict PENDING */
 			info.verdict_id = snet_verdict_insert();
@@ -242,7 +245,8 @@ static int snet_socket_connect(struct socket *sock,
 			       sizeof(info.dst.u3.ip6));
 			info.dst.u.port = ntohs(a6->sin6_port);
 			/* check tickets */
-			if ((verdict = snet_ticket_check(&info)) != SNET_VERDICT_NONE)
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
 				goto out;
 			/* inserting verdict PENDING */
 			info.verdict_id = snet_verdict_insert();
@@ -295,7 +299,8 @@ static int snet_socket_listen(struct socket *sock, int backlog)
 			info.src.u3.ip = inet->inet_saddr;
 			info.dst.u3.ip = inet->inet_daddr;
 			/* check tickets */
-			if ((verdict = snet_ticket_check(&info)) != SNET_VERDICT_NONE)
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
 				goto out;
 			/* inserting verdict PENDING */
 			info.verdict_id = snet_verdict_insert();
@@ -306,7 +311,9 @@ static int snet_socket_listen(struct socket *sock, int backlog)
 			       sizeof(info.src.u3.ip6));
 			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
 			       sizeof(info.dst.u3.ip6));
-			if ((verdict = snet_ticket_check(&info)) != SNET_VERDICT_NONE)
+			/* check tickets */
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
 				goto out;
 			/* inserting verdict PENDING */
 			info.verdict_id = snet_verdict_insert();
@@ -358,7 +365,8 @@ static int snet_socket_accept(struct socket *sock, struct socket *newsock)
 			info.src.u3.ip = inet->inet_saddr;
 			info.dst.u3.ip = inet->inet_daddr;
 			/* check tickets */
-			if ((verdict = snet_ticket_check(&info)) != SNET_VERDICT_NONE)
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
 				goto out;
 			/* inserting verdict PENDING */
 			info.verdict_id = snet_verdict_insert();
@@ -370,7 +378,8 @@ static int snet_socket_accept(struct socket *sock, struct socket *newsock)
 			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
 			       sizeof(info.dst.u3.ip6));
 			/* check tickets */
-			if ((verdict = snet_ticket_check(&info)) != SNET_VERDICT_NONE)
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
 				goto out;
 			/* inserting verdict PENDING */
 			info.verdict_id = snet_verdict_insert();
@@ -470,7 +479,8 @@ static int snet_socket_sendmsg(struct socket *sock,
 			info.src.u3.ip = inet->inet_saddr;
 			info.dst.u3.ip = inet->inet_daddr;
 			/* check tickets */
-			if ((verdict = snet_ticket_check(&info)) != SNET_VERDICT_NONE)
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
 				goto out;
 			/* inserting verdict PENDING */
 			info.verdict_id = snet_verdict_insert();
@@ -482,7 +492,8 @@ static int snet_socket_sendmsg(struct socket *sock,
 			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
 			       sizeof(info.dst.u3.ip6));
 			/* check tickets */
-			if ((verdict = snet_ticket_check(&info)) != SNET_VERDICT_NONE)
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
 				goto out;
 			/* inserting verdict PENDING */
 			info.verdict_id = snet_verdict_insert();
@@ -535,7 +546,8 @@ static int snet_socket_recvmsg(struct socket *sock,
 			info.src.u3.ip = inet->inet_saddr;
 			info.dst.u3.ip = inet->inet_daddr;
 			/* check tickets */
-			if ((verdict = snet_ticket_check(&info)) != SNET_VERDICT_NONE)
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
 				goto out;
 			/* inserting verdict PENDING */
 			info.verdict_id = snet_verdict_insert();
@@ -547,7 +559,8 @@ static int snet_socket_recvmsg(struct socket *sock,
 			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
 			       sizeof(info.dst.u3.ip6));
 			/* check tickets */
-			if ((verdict = snet_ticket_check(&info)) != SNET_VERDICT_NONE)
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
 				goto out;
 			/* inserting verdict PENDING */
 			info.verdict_id = snet_verdict_insert();
-- 
1.6.3.3

