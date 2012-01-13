From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v5 0/6] SUNRPC: rcbind clients virtualization
Date: Fri, 13 Jan 2012 12:52:01 +0400
Message-ID: <20120113084545.31750.83655.stgit@localhost6.localdomain6>
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
head: devel

v5:
1) Rebased on up-to-date state ("devel" head).
2) Added two more patches from latter series ("SUNRPC: register services with
per-net rpcbind"), because logically this series is the more suitable place for
them.

v4:
1) Rebased of current repo state (i.e. all commits pulled before apply)

v3:
1) First two patches from previous version were squashed.

This patch-set virtualizes rpcbind clients per network namespace context. IOW,
each network namespace will have its own pair of rpcbind clients (if they would
be created by request).

The following series consists of:

---

Stanislav Kinsbursky (6):
      SUNRPC: move rpcbind internals to sunrpc part of network namespace context
      SUNRPC: optimize net_ns dereferencing in rpcbind creation calls
      SUNRPC: optimize net_ns dereferencing in rpcbind registering calls
      SUNRPC: create rpcbind client in passed network namespace context
      SUNRPC: register rpcbind programs in passed network namespase context
      SUNRPC: parametrize local rpcbind clients creation with net ns


 include/linux/sunrpc/clnt.h |    9 ++-
 net/sunrpc/netns.h          |    5 ++
 net/sunrpc/rpcb_clnt.c      |  121 +++++++++++++++++++++++--------------------
 net/sunrpc/svc.c            |   14 ++---
 4 files changed, 82 insertions(+), 67 deletions(-)
