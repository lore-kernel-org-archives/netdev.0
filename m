From: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Date: Wed, 29 Dec 2010 15:14:18 +0200
Message-ID: <1293628470-28386-1-git-send-email-kas@openvz.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
Only for client for now.

Changelog:

 v2:
  - one of rpc_create() calls was missed initially, fixed;
  - change logic for get_rpc_pipefs(NULL);
  - export get_rpc_pipefs() to be able to use from modules
    (tnx J. Bruce Field);
  - change "From:" and "Signed-off-by:" addresses.

 v1:
  - initial revision of the patchset.

Kirill A. Shutemov (12):
  sunrpc: mount rpc_pipefs on initialization
  sunrpc: introduce init_rpc_pipefs
  sunrpc: push init_rpc_pipefs up to rpc_create() callers
  sunrpc: tag svc_serv with rpc_pipefs mount point
  sunrpc: get rpc_pipefs mount point for svc_serv from callers
  lockd: get rpc_pipefs mount point from callers
  sunrpc: get rpc_pipefs mount point for rpcb_create[_local] from callers
  sunrpc: tag pipefs field of cache_detail with rpc_pipefs mount point
  nfs: per-rpc_pipefs dns cache
  sunrpc: introduce get_rpc_pipefs()
  nfs: introduce mount option 'rpcmount'
  sunrpc: make rpc_pipefs be mountable multiple times

 fs/lockd/clntlock.c                |    8 +-
 fs/lockd/host.c                    |   12 +++-
 fs/lockd/mon.c                     |   13 ++-
 fs/lockd/svc.c                     |    4 +-
 fs/nfs/cache_lib.c                 |   18 +---
 fs/nfs/cache_lib.h                 |    3 +-
 fs/nfs/callback.c                  |    6 +-
 fs/nfs/callback.h                  |    3 +-
 fs/nfs/client.c                    |   45 +++++++++--
 fs/nfs/dns_resolve.c               |  128 +++++++++++++++++++++++------
 fs/nfs/dns_resolve.h               |    8 +--
 fs/nfs/inode.c                     |    8 +--
 fs/nfs/internal.h                  |   10 ++-
 fs/nfs/mount_clnt.c                |    1 +
 fs/nfs/namespace.c                 |    3 +-
 fs/nfs/nfs4namespace.c             |   20 +++--
 fs/nfs/super.c                     |   20 +++++
 fs/nfsd/nfs4callback.c             |    2 +
 fs/nfsd/nfssvc.c                   |    8 +-
 include/linux/lockd/bind.h         |    3 +-
 include/linux/lockd/lockd.h        |    4 +-
 include/linux/nfs_fs_sb.h          |    1 +
 include/linux/sunrpc/cache.h       |    9 +--
 include/linux/sunrpc/clnt.h        |    5 +-
 include/linux/sunrpc/rpc_pipe_fs.h |    6 +-
 include/linux/sunrpc/svc.h         |    9 +-
 net/sunrpc/cache.c                 |   16 +++--
 net/sunrpc/clnt.c                  |   19 +++--
 net/sunrpc/rpc_pipe.c              |  156 ++++++++++++++++++++++++++++++-----
 net/sunrpc/rpcb_clnt.c             |   19 +++--
 net/sunrpc/svc.c                   |   52 ++++++++-----
 31 files changed, 448 insertions(+), 171 deletions(-)

-- 
1.7.3.4

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
