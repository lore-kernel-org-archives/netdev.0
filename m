From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [Patch] scm: Capture the full credentials of the scm sender
Date: Tue, 09 Aug 2011 09:48:32 -0700
Message-ID: <1312908512.2576.97.camel@schen9-DESK>
References: <1312841316.2576.49.camel@schen9-DESK>
	 <1312857834.2531.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>, ak@linux.intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47429 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753595Ab1HIQrf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 12:47:35 -0400
In-Reply-To: <1312857834.2531.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-08-09 at 04:43 +0200, Eric Dumazet wrote:

> Good catch Tim.
> 
> BTW your patch is a bit flawed : one wrapped line and "---" marker
> missing.
> 
> Could you add in Changelog bug came from commit 257b5358b32f17
> (scm: Capture the full credentials of the scm sender) to ease stable
> teams work ?
> (linux-2.6.36 was the first kernel to include this commit)
> 
> 
> 

Updated the log as requested.  Thanks.

Tim

------------

This patch corrects an erroneous update of credential's gid with uid
introduced in commit 257b5358b32f17 since 2.6.36.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
diff --git a/net/core/scm.c b/net/core/scm.c
index 4c1ef02..811b53f 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -192,7 +192,7 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 					goto error;
 
 				cred->uid = cred->euid = p->creds.uid;
-				cred->gid = cred->egid = p->creds.uid;
+				cred->gid = cred->egid = p->creds.gid;
 				put_cred(p->cred);
 				p->cred = cred;
 			}


