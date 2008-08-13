From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH] dccp: change L/R must have at least one byte in the
	dccpsf_val field
Date: Wed, 13 Aug 2008 09:55:32 -0300
Message-ID: <20080813125532.GD12888@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44559 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752582AbYHMM5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 08:57:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Gerrit,

	Please consider applying.

- Arnaldo

dccp: change L/R must have at least one byte in the dccpsf_val field
    
Thanks to Eugene Teo for reporting this problem.
    
Signed-off-by: Eugene Teo <eugenete@kernel.sg>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index b622d97..1ca3b26 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -474,6 +474,11 @@ static int dccp_setsockopt_change(struct sock *sk, int type,
 
 	if (copy_from_user(&opt, optval, sizeof(opt)))
 		return -EFAULT;
+	/*
+	 * rfc4340: 6.1. Change Options
+	 */
+	if (opt.dccpsf_len < 1)
+		return -EINVAL;
 
 	val = kmalloc(opt.dccpsf_len, GFP_KERNEL);
 	if (!val)



