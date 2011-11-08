From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v4 0/3] SUNRPC: rcbind clients virtualization
Date: Tue, 08 Nov 2011 14:41:05 +0300
Message-ID: <20111108104023.1714.87978.stgit@localhost6.localdomain6>
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

This patch-set was created in context of clone of git branch:
git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.

v4:
1) Rebased of current repo state (i.e. all commits pulled before apply)

v3:
1) First two patches from previous version were squashed.

I feel it is ready for inclusion when the next merge window opens if no
objections wil appear.

This patch-set virtualizes rpcbind clients per network namespace context. IOW,
each network namespace will have its own pair of rpcbind clients (if they would
be created by request).

Note:
init_net pointer is still used instead of current->nsproxy->net_ns, because I'm
not sure yet about how to virtualize services. I.e. NFS callback services will
be per netns. NFSd service will be per netns too from my pow. But Lockd can be
per netns or one for all. And also we have NFSd file system, which is not
virtualized yet.

The following series consists of:

---

Stanislav Kinsbursky (3):
      SUNRPC: move rpcbind internals to sunrpc part of network namespace context
      SUNRPC: optimize net_ns dereferencing in rpcbind creation calls
      SUNRPC: optimize net_ns dereferencing in rpcbind registering calls


 net/sunrpc/netns.h     |    5 ++
 net/sunrpc/rpcb_clnt.c |  103 ++++++++++++++++++++++++++----------------------
 2 files changed, 61 insertions(+), 47 deletions(-)

-- 
Signature
