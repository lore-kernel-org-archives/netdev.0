From: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 00/23] various networking refcount conversions, part 2
Date: Fri, 17 Mar 2017 14:10:23 +0200
Message-ID: <1489752646-8749-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-x25-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vyasevich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        zyan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sage-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
        jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org, steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org,
        herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
        jreuter-K7Hl1MveuGQ@public.gmane.org, ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
        keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series, for the rest of network subsystem components, replaces atomic_t reference
counters with the new refcount_t type and API (see include/linux/refcount.h).
By doing this we prevent intentional or accidental
underflows or overflows that can led to use-after-free vulnerabilities.

The patches are fully independent and can be cherry-picked separately.
Since we convert all kernel subsystems in the same fashion, resulting
in about 300 patches, we have to group them for sending at least in some
fashion to be manageable. Please excuse the long cc list.

If there are no objections to the patches, please merge them via respective trees.

Elena Reshetova (23):
  net, sunrpc: convert rpc_cred.cr_count from atomic_t to refcount_t
  net, sunrpc: convert gss_cl_ctx.count from atomic_t to refcount_t
  net, sunrpc: convert gss_upcall_msg.count from atomic_t to refcount_t
  net, ceph: convert ceph_snap_context.nref from atomic_t to refcount_t
  net, ceph: convert ceph_osd.o_ref from atomic_t to refcount_t
  net, ceph: convert ceph_pagelist.refcnt from atomic_t to refcount_t
  net, rds: convert rds_ib_device.refcount from atomic_t to refcount_t
  net, rds: convert rds_incoming.i_refcount from atomic_t to refcount_t
  net, rds: convert rds_mr.r_refcount from atomic_t to refcount_t
  net, rds: convert rds_message.m_refcount from atomic_t to refcount_t
  net, x25: convert x25_route.refcnt from atomic_t to refcount_t
  net, x25: convert x25_neigh.refcnt from atomic_t to refcount_t
  net, xfrm: convert xfrm_state.refcnt from atomic_t to refcount_t
  net, xfrm: convert xfrm_policy.refcnt from atomic_t to refcount_t
  net, xfrm: convert sec_path.refcnt from atomic_t to refcount_t
  net, sctp: convert sctp_auth_bytes.refcnt from atomic_t to refcount_t
  net, sctp: convert sctp_datamsg.refcnt from atomic_t to refcount_t
  net, sctp: convert sctp_chunk.refcnt from atomic_t to refcount_t
  net, sctp: convert sctp_transport.refcnt from atomic_t to refcount_t
  net, sctp: convert sctp_ep_common.refcnt from atomic_t to refcount_t
  net, ax25: convert ax25_uid_assoc.refcount from atomic_t to refcount_t
  net, ax25: convert ax25_route.refcount from atomic_t to refcount_t
  net, ax25: convert ax25_cb.refcount from atomic_t to refcount_t

 fs/ceph/mds_client.c            |  2 +-
 include/linux/ceph/libceph.h    |  3 ++-
 include/linux/ceph/osd_client.h |  3 ++-
 include/linux/ceph/pagelist.h   |  6 +++---
 include/linux/sunrpc/auth.h     |  8 ++++----
 include/linux/sunrpc/auth_gss.h |  3 ++-
 include/net/ax25.h              | 20 ++++++++++----------
 include/net/sctp/auth.h         |  5 +++--
 include/net/sctp/structs.h      |  8 ++++----
 include/net/x25.h               | 13 +++++++------
 include/net/xfrm.h              | 21 +++++++++++----------
 net/ax25/af_ax25.c              |  2 +-
 net/ax25/ax25_route.c           |  2 +-
 net/ax25/ax25_uid.c             |  2 +-
 net/ceph/osd_client.c           | 16 ++++++++--------
 net/ceph/pagelist.c             |  2 +-
 net/ceph/snapshot.c             |  6 +++---
 net/key/af_key.c                |  2 +-
 net/rds/ib.c                    | 12 ++++++------
 net/rds/ib.h                    |  2 +-
 net/rds/ib_rdma.c               |  4 ++--
 net/rds/message.c               | 12 ++++++------
 net/rds/rdma.c                  | 10 +++++-----
 net/rds/rds.h                   |  9 +++++----
 net/rds/recv.c                  | 12 ++++++------
 net/sctp/associola.c            |  6 +++---
 net/sctp/auth.c                 |  4 ++--
 net/sctp/chunk.c                |  6 +++---
 net/sctp/endpointola.c          |  6 +++---
 net/sctp/sm_make_chunk.c        |  6 +++---
 net/sctp/transport.c            |  8 ++++----
 net/sunrpc/auth.c               | 12 ++++++------
 net/sunrpc/auth_gss/auth_gss.c  | 28 ++++++++++++++--------------
 net/x25/x25_link.c              |  2 +-
 net/x25/x25_route.c             |  2 +-
 net/xfrm/xfrm_input.c           |  4 ++--
 net/xfrm/xfrm_policy.c          |  4 ++--
 net/xfrm/xfrm_state.c           |  4 ++--
 38 files changed, 142 insertions(+), 135 deletions(-)

-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
