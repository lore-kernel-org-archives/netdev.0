From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] sctp: jsctp_sf_eat_sack: fix jprobes function signature mismatch
Date: Sat, 15 Dec 2012 21:12:43 +0100
Message-ID: <a910a63d58d95aed8caeea8a43a21cab863b3bfb.1355602097.git.dborkman@redhat.com>
References: <cover.1355602097.git.dborkman@redhat.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41417 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329Ab2LOUMs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Dec 2012 15:12:48 -0500
In-Reply-To: <cover.1355602097.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 24cb81a6a (sctp: Push struct net down into all of the
state machine functions) introduced the net structure into all
state machine functions, but jsctp_sf_eat_sack was not updated,
hence when SCTP association probing is enabled in the kernel,
any simple SCTP client/server program from userspace will panic
the kernel.

Cc: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/probe.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index bc6cd75..5f7518d 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -122,7 +122,8 @@ static const struct file_operations sctpprobe_fops = {
 	.llseek = noop_llseek,
 };
 
-sctp_disposition_t jsctp_sf_eat_sack(const struct sctp_endpoint *ep,
+sctp_disposition_t jsctp_sf_eat_sack(struct net *net,
+				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
 				     const sctp_subtype_t type,
 				     void *arg,
-- 
1.7.11.7
