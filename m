From: David Howells <dhowells@redhat.com>
Subject: [PATCH 51/59] CRED: Wrap task credential accesses in the IPv6 protocol
Date: Wed, 27 Aug 2008 14:50:05 +0100
Message-ID: <20080827135005.19980.38281.stgit@warthog.procyon.org.uk>
References: <20080827134541.19980.61042.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org,
	David Howells <dhowells@redhat.com>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59554 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758377AbYH0Nxf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 09:53:35 -0400
In-Reply-To: <20080827134541.19980.61042.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrap access to task credentials so that they can be separated more easily from
the task_struct during the introduction of COW creds.

Change most current->(|e|s|fs)[ug]id to current_(|e|s|fs)[ug]id().

Change some task->e?[ug]id to task_e?[ug]id().  In some places it makes more
sense to use RCU directly rather than a convenient wrapper; these will be
addressed by later patches.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: James Morris <jmorris@namei.org>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Cc: netdev@vger.kernel.org
---

 net/ipv6/ip6_flowlabel.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 37a4e77..bd3c7b9 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -388,7 +388,7 @@ fl_create(struct net *net, struct in6_flowlabel_req *freq, char __user *optval,
 		fl->owner = current->pid;
 		break;
 	case IPV6_FL_S_USER:
-		fl->owner = current->euid;
+		fl->owner = current_euid();
 		break;
 	default:
 		err = -EINVAL;

