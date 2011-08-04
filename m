From: "Serge E. Hallyn" <serge.hallyn@canonical.com>
Subject: Re: [PATCH 10/14] net/core/scm.c: target capable() calls to user_ns
 owning the net_ns
Date: Thu, 4 Aug 2011 17:06:02 -0500
Message-ID: <20110804220602.GA32347@sergelap>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
 <1311706717-7398-11-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, dhowells@redhat.com,
	ebiederm@xmission.com, containers@lists.linux-foundation.org,
	netdev@vger.kernel.org, akpm@osdl.org
To: Serge Hallyn <serge@hallyn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:35185 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755795Ab1HDWGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 18:06:08 -0400
Content-Disposition: inline
In-Reply-To: <1311706717-7398-11-git-send-email-serge@hallyn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Serge Hallyn (serge@hallyn.com):
> From: Serge E. Hallyn <serge.hallyn@canonical.com>
> 
> The uid/gid comparisons don't have to be pulled out.  This just seemed
> more easily proved correct.

The following needs to be folded into this patch:

From: Serge Hallyn <serge.hallyn@canonical.com>
Date: Thu, 4 Aug 2011 21:48:13 +0000
Subject: [PATCH 2/2] fold up - net/core/scm.c: cred is const

Signed-off-by: Serge Hallyn <serge.hallyn@canonical.com>
---
 net/core/scm.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/scm.c b/net/core/scm.c
index 21b5d0b..528fa36 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -43,7 +43,7 @@
  *	setu(g)id.
  */
 
-static __inline__ bool uidequiv(struct cred *src, struct ucred *tgt,
+static __inline__ bool uidequiv(const struct cred *src, struct ucred *tgt,
 			       struct user_namespace *ns)
 {
 	if (src->user_ns != ns)
@@ -57,7 +57,7 @@ check_capable:
 	return false;
 }
 
-static __inline__ bool gidequiv(struct cred *src, struct ucred *tgt,
+static __inline__ bool gidequiv(const struct cred *src, struct ucred *tgt,
 			       struct user_namespace *ns)
 {
 	if (src->user_ns != ns)
-- 
1.7.5.4

