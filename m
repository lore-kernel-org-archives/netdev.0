From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v3 0/4] SUNRPC: several fixes around PipeFS objects
Date: Mon, 27 Feb 2012 22:05:20 +0400
Message-ID: <20120227180509.1089.29555.stgit@localhost6.localdomain6>
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

v3:
1) Lookup for client is performed from the beginning of the list on each PipeFS
event handling operation.

v2: 
1) Prior to calling PipeFS dentry rountines (for both type of clients - SUNPRC
and NFS) get the client and drop the list lock instead of replacing per-net
locks by mutexes.

First two pathes fixes lockdep warnings and next two - dereferencing of
released pipe data on eventfd close and in file operations.

The following series consists of:

---

Stanislav Kinsbursky (4):
      SUNRPC: release per-net clients lock before calling PipeFS dentries creation
      NFS: release per-net clients lock before calling PipeFS dentries creation
      SUNRPC: check RPC inode's pipe reference before dereferencing
      SUNRPC: move waitq from RPC pipe to RPC inode


 fs/nfs/idmap.c                     |   30 ++++++++++++---
 include/linux/sunrpc/rpc_pipe_fs.h |    2 +
 net/sunrpc/clnt.c                  |   30 ++++++++++++---
 net/sunrpc/rpc_pipe.c              |   71 +++++++++++++++++++++++-------------
 4 files changed, 93 insertions(+), 40 deletions(-)
