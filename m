From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 0/2] SUNRPC: pipefs virtualization
Date: Mon, 12 Sep 2011 18:19:34 +0400
Message-ID: <20110912141633.6261.72180.stgit@localhost6.localdomain6>
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

This patch set is a part of further RPC layer virtualization and it's aim is to
make RPC pipefs mount creation and destruction per network namespace context.
It moves RPC pipefs internal data to sunrpc_net instance of network namespace
context.
With this patch set all calls to pipefs infrastructure are performed with
"&init_net" except rpc_new_client() and rpc_setup_pipedir() functions (but they
still passes pointer to "init_net" by current design).
This "init_net" pointer will be replaced later with NFS virtualization.

The following series consists of:

---

Stanislav Kinsbursky (2):
      SUNRPC: make rpc pipefs mount per network namespace
      SUNRPC: RPC pipefs virtualization


 fs/nfs/blocklayout/blocklayout.c   |    2 +-
 fs/nfs/cache_lib.c                 |    7 ++++---
 include/linux/sunrpc/rpc_pipe_fs.h |    4 ++--
 net/sunrpc/clnt.c                  |    8 ++++----
 net/sunrpc/netns.h                 |    3 +++
 net/sunrpc/rpc_pipe.c              |   23 +++++++++++++++--------
 6 files changed, 29 insertions(+), 18 deletions(-)

-- 
Signature
