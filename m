From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 00/16] generic hashtable implementation
Date: Tue, 14 Aug 2012 18:24:34 +0200
Message-ID: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org,
	Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

There are quite a few places in the kernel which implement a hashtable
in a very similar way. Instead of having implementations of a hashtable
all over the kernel, we can re-use the code.

New changes since the RFC:

 - Addressed last comments about previous patches.
 - RCU support.
 - Simplified the case where the hashtable is allocated statically, which is
 the common case.
 - A lot more places converted to use the new hashtable.


Sasha Levin (16):
  hashtable: introduce a small and naive hashtable
  user_ns: use new hashtable implementation
  mm,ksm: use new hashtable implementation
  workqueue: use new hashtable implementation
  mm/huge_memory: use new hashtable implementation
  tracepoint: use new hashtable implementation
  net,9p: use new hashtable implementation
  block,elevator: use new hashtable implementation
  SUNRPC/cache: use new hashtable implementation
  dlm: use new hashtable implementation
  net,l2tp: use new hashtable implementation
  dm: use new hashtable implementation
  lockd: use new hashtable implementation
  net,rds: use new hashtable implementation
  openvswitch: use new hashtable implementation
  tracing output: use new hashtable implementation

 block/blk.h                                        |    2 +-
 block/elevator.c                                   |   23 +--
 drivers/md/dm-snap.c                               |   24 +--
 drivers/md/persistent-data/dm-block-manager.c      |    1 -
 .../persistent-data/dm-persistent-data-internal.h  |   19 --
 .../md/persistent-data/dm-transaction-manager.c    |   30 +--
 fs/dlm/lowcomms.c                                  |   47 +---
 fs/lockd/svcsubs.c                                 |   58 ++--
 include/linux/elevator.h                           |    5 +-
 include/linux/hashtable.h                          |  284 ++++++++++++++++++++
 kernel/trace/trace_output.c                        |   20 +-
 kernel/tracepoint.c                                |   27 +--
 kernel/user.c                                      |   33 +--
 kernel/workqueue.c                                 |   86 +-----
 mm/huge_memory.c                                   |   57 +---
 mm/ksm.c                                           |   33 +--
 net/9p/error.c                                     |   21 +-
 net/l2tp/l2tp_core.c                               |  132 ++++------
 net/l2tp/l2tp_core.h                               |    8 +-
 net/l2tp/l2tp_debugfs.c                            |   19 +-
 net/openvswitch/vport.c                            |   30 +--
 net/rds/bind.c                                     |   20 +-
 net/rds/connection.c                               |  102 +++----
 net/sunrpc/cache.c                                 |   20 +-
 24 files changed, 573 insertions(+), 528 deletions(-)
 delete mode 100644 drivers/md/persistent-data/dm-persistent-data-internal.h
 create mode 100644 include/linux/hashtable.h

-- 
1.7.8.6
