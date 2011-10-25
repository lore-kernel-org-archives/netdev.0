From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v6 0/8] SUNRPC: make rpcbind clients allocated and destroyed
	dynamically
Date: Tue, 25 Oct 2011 14:15:58 +0300
Message-ID: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bfields@fieldses.org, davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch-set was created in context of clone of git branch:
git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git
and rebased on tag "v3.1".

2 Trond:
Nothing changed against previous patch-set we discussed already.
If no other issues will appear against it, hoping for soon commit.
If git repo, mentioned above, is not suitable for development purposes, please,
reply with the right one.

v6:
1) Fixes in rpcb_clients management.

v4:
1) creation and destruction on rpcbind clients now depends on service program
versions "vs_hidden" flag.

This patch is required for further RPC layer virtualization, because rpcbind
clients have to be per network namespace.
To achive this, we have to untie network namespace from rpcbind clients sockets.
The idea of this patch set is to make rpcbind clients non-static. I.e. rpcbind
clients will be created during first RPC service creation, and destroyed when
last RPC service is stopped.
With this patch set rpcbind clients can be virtualized easely.

The following series consists of:

---

Stanislav Kinsbursky (8):
      SUNRPC: introduce helpers for reference counted rpcbind clients
      SUNRPC: use rpcbind reference counting helpers
      SUNRPC: introduce svc helpers for prepairing rpcbind infrastructure
      SUNRPC: setup rpcbind clients if service requires it
      SUNRPC: cleanup service destruction
      NFSd: call svc rpcbind cleanup explicitly
      SUNRPC: remove rpcbind clients creation during service registering
      SUNRPC: remove rpcbind clients destruction on module cleanup


 fs/nfsd/nfssvc.c            |    2 +
 include/linux/sunrpc/clnt.h |    2 +
 include/linux/sunrpc/svc.h  |    1 
 net/sunrpc/rpcb_clnt.c      |   89 +++++++++++++++++++++++++++++--------------
 net/sunrpc/sunrpc_syms.c    |    3 -
 net/sunrpc/svc.c            |   48 ++++++++++++++++++++++-
 6 files changed, 109 insertions(+), 36 deletions(-)

-- 
Signature
