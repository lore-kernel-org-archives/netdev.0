From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 0/6] SUNRPC: make RPC clients use network-namespace-aware
	PipeFS routines
Date: Wed, 23 Nov 2011 14:51:10 +0300
Message-ID: <20111123104945.11077.10270.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, davem@davemloft.net, devel@openvz.org
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set was created in context of clone of git
branch: git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
tag: v3.1

This patch set depends on previous patch sets titled:
1) "SUNRPC: initial part of making pipefs work in net ns"
2) "SUNPRC: cleanup PipeFS for network-namespace-aware users"

This patch set is a first part of reworking SUNPRC PipeFS users.
It makes SUNRPC clients using PipeFS nofitications for directory and GSS pipes
dentries creation. With this patch set RPC clients and GSS auth creations
routines doesn't force SUNRPC PipeFS mount point creation which actually means,
that they now can work without PipeFS dentries.

The following series consists of:

---

Stanislav Kinsbursky (6):
      SUNRPC: handle RPC client pipefs dentries by network namespace aware routines
      SUNRPC: handle GSS AUTH pipes by network namespace aware routines
      SUNRPC: subscribe RPC clients to pipefs notifications
      SUNRPC: remove RPC client pipefs dentries after unregister
      SUNRPC: remove RPC pipefs mount point manipulations from RPC clients code
      SUNRPC: remove RPC PipeFS mount point reference from RPC client


 fs/nfs/idmap.c                 |    4 +
 fs/nfsd/nfs4callback.c         |    2 -
 include/linux/nfs.h            |    2 -
 include/linux/sunrpc/auth.h    |    2 +
 include/linux/sunrpc/clnt.h    |    2 -
 net/sunrpc/auth_gss/auth_gss.c |  101 +++++++++++++++++++++------
 net/sunrpc/clnt.c              |  151 +++++++++++++++++++++++++++++++---------
 net/sunrpc/rpc_pipe.c          |   19 +++--
 net/sunrpc/sunrpc.h            |    2 +
 9 files changed, 218 insertions(+), 67 deletions(-)

-- 
Signature
