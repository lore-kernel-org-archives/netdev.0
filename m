From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v4 0/8] SUNRPC: make rpcbind clients allocated and destroyed
	dynamically
Date: Tue, 20 Sep 2011 14:13:32 +0400
Message-ID: <20110920101031.9861.18444.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bfields@fieldses.org, davem@davemloft.net
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 include/linux/sunrpc/svc.h  |    1 +
 net/sunrpc/rpcb_clnt.c      |   85 ++++++++++++++++++++++++++++---------------
 net/sunrpc/sunrpc_syms.c    |    3 --
 net/sunrpc/svc.c            |   48 +++++++++++++++++++++++-
 6 files changed, 105 insertions(+), 36 deletions(-)

-- 
Signature
