From: Dan Carpenter <error27@gmail.com>
Subject: [patch 2/2] 9p: change an int to unsigned int
Date: Fri, 26 Aug 2011 19:57:40 +0300
Message-ID: <20110826165740.GF3775@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"Venkateswararao Jujjuri (JV)" <jvrao@linux.vnet.ibm.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	"M. Mohan Kumar" <mohan@in.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:61645 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816Ab1HZRAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 13:00:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The size of things should be unsigned because negative sizes are
silly.  My concern is the the limit checks don't take negative values
into consideration in p9_client_create()
	if (clnt->msize > clnt->trans_mod->maxsize)
		clnt->msize = clnt->trans_mod->maxsize;
and in p9_tag_alloc()
	int alloc_msize = min(c->msize, max_size);

I don't know if this is exported to user space?  Hopefully it's not
too late to change this.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/include/net/9p/client.h b/include/net/9p/client.h
index 55ce72c..d479d7d 100644
--- a/include/net/9p/client.h
+++ b/include/net/9p/client.h
@@ -151,7 +151,7 @@ struct p9_req_t {
 
 struct p9_client {
 	spinlock_t lock; /* protect client structure */
-	int msize;
+	unsigned int msize;
 	unsigned char proto_version;
 	struct p9_trans_module *trans_mod;
 	enum p9_trans_status status;
