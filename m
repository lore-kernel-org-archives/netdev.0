From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 0/4] SUNRPC: several fixes around PipeFS objects
Date: Mon, 27 Feb 2012 17:48:43 +0400
Message-ID: <20120227134623.13371.61185.stgit@localhost6.localdomain6>
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

First two pathes fixes lockdep warnings and next two - dereferencing of
released pipe data on eventfd close.

The following series consists of:

---

Stanislav Kinsbursky (4):
      SUNRPC: replace per-net client lock by rw mutex
      NFS: replace per-net client lock by mutex
      SUNRPC: check RPC inode's pipe reference before dereferencing
      SUNRPC: move waitq from RPC pipe to RPC inode


 fs/nfs/client.c                    |   36 +++++++++---------
 fs/nfs/idmap.c                     |    4 +-
 fs/nfs/netns.h                     |    2 +
 include/linux/sunrpc/rpc_pipe_fs.h |    2 +
 net/sunrpc/clnt.c                  |   16 ++++----
 net/sunrpc/netns.h                 |    2 +
 net/sunrpc/rpc_pipe.c              |   71 +++++++++++++++++++++++-------------
 net/sunrpc/sunrpc_syms.c           |    2 +
 8 files changed, 77 insertions(+), 58 deletions(-)
