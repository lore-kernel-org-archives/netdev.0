From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v3 08/11] NFSd: force creation of rpcbind clients during
	service creation
Date: Tue, 13 Sep 2011 22:14:22 +0400
Message-ID: <20110913181421.3961.81050.stgit@localhost6.localdomain6>
References: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bfields@fieldses.org, davem@davemloft.net
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NFSd sends requests to portmapper and thus requires rpcbind clients.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/nfssvc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index dc5a1bf..88faab8 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -332,7 +332,7 @@ int nfsd_create_serv(void)
 	nfsd_reset_versions();
 
 	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-				      nfsd_last_thread, nfsd, THIS_MODULE);
+				      1, nfsd_last_thread, nfsd, THIS_MODULE);
 	if (nfsd_serv == NULL)
 		return -ENOMEM;
 
