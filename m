From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH] NFS: parse DNS cache in proper network namespace context
Date: Thu, 19 Jan 2012 18:51:04 +0400
Message-ID: <20120119145052.10480.1059.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces "init_net" with cache's owner net in rpc_pton() call.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/dns_resolve.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index 7edc62a..be9a530 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -224,7 +224,7 @@ static int nfs_dns_parse(struct cache_detail *cd, char *buf, int buflen)
 	len = qword_get(&buf, buf1, sizeof(buf1));
 	if (len <= 0)
 		goto out;
-	key.addrlen = rpc_pton(&init_net, buf1, len,
+	key.addrlen = rpc_pton(cd->net, buf1, len,
 			(struct sockaddr *)&key.addr,
 			sizeof(key.addr));
 
