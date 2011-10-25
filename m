From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v2 0/4] Series short description
Date: Tue, 25 Oct 2011 17:57:40 +0300
Message-ID: <20111025135637.5286.89632.stgit@localhost6.localdomain6>
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

This patch-set virtualizes rpcbind clients per network namespace context. IOW,
each network namespace will have its own pair of rpcbind clients (if the would
be created by request).

Note:
1) this patch-set depends on "SUNRPC: make rpcbind clients allocated and
destroyed dynamically" patch-set which has been send earlier.
2) init_net pointer is still used instead of current->nsproxy->net_ns,
because I'm not sure yet about how to virtualize services.
I.e. NFS callback services will be per netns. NFSd service will be per netns
too from my pow. But Lockd can be per netns or one for all.
And also we have NFSd file system, which is not virtualized yet.

The following series consists of:

---

Stanislav Kinsbursky (4):
      SUNRPC: rpcbind clients internals virtualization
      SUNRPC: use virtualized rpcbind internals instead of static ones
      SUNRPC: optimize net_ns dereferencing in rpcbind creation calls
      SUNRPC: optimize net_ns dereferencing in rpcbind registering calls


 net/sunrpc/netns.h     |    5 ++
 net/sunrpc/rpcb_clnt.c |  103 ++++++++++++++++++++++++++----------------------
 2 files changed, 61 insertions(+), 47 deletions(-)

-- 
Signature
