From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next repost 1/3] idr: Use unsigned long instead of int
Date: Wed, 16 Aug 2017 12:53:05 +0200
Message-ID: <20170816105305.GH1868@nanopsycho>
References: <1502871244-19870-1-git-send-email-chrism@mellanox.com>
 <1502871244-19870-2-git-send-email-chrism@mellanox.com>
 <1502879829.4936.100.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Mi <chrism@mellanox.com>, netdev@vger.kernel.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, davem@davemloft.net,
        mawilcox@microsoft.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34217 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751068AbdHPKxI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 06:53:08 -0400
Received: by mail-wr0-f193.google.com with SMTP id x43so2364830wrb.1
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 03:53:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1502879829.4936.100.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 16, 2017 at 12:37:09PM CEST, eric.dumazet@gmail.com wrote:
>On Wed, 2017-08-16 at 04:14 -0400, Chris Mi wrote:
>> IDR uses internally radix tree which uses unsigned long. It doesn't
>> makes sense to have index as signed value.
>> 
>> Signed-off-by: Chris Mi <chrism@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  block/bsg.c                                     |  8 ++--
>>  block/genhd.c                                   | 12 +++---
>>  drivers/atm/nicstar.c                           | 11 ++---
>>  drivers/block/drbd/drbd_main.c                  | 31 ++++++++------
>>  drivers/block/drbd/drbd_nl.c                    | 22 +++++-----
>>  drivers/block/drbd/drbd_proc.c                  |  3 +-
>>  drivers/block/drbd/drbd_receiver.c              | 15 ++++---
>>  drivers/block/drbd/drbd_state.c                 | 34 ++++++++-------
>>  drivers/block/drbd/drbd_worker.c                |  6 +--
>>  drivers/block/loop.c                            | 17 +++++---
>>  drivers/block/nbd.c                             | 20 +++++----
>>  drivers/block/zram/zram_drv.c                   |  9 ++--
>>  drivers/char/tpm/tpm-chip.c                     | 10 +++--
>>  drivers/char/tpm/tpm.h                          |  2 +-
>>  drivers/dca/dca-sysfs.c                         |  9 ++--
>>  drivers/firewire/core-cdev.c                    | 18 ++++----
>>  drivers/firewire/core-device.c                  | 15 ++++---
>>  drivers/gpu/drm/amd/amdgpu/amdgpu_bo_list.c     |  8 ++--
>>  drivers/gpu/drm/amd/amdgpu/amdgpu_ctx.c         |  9 ++--
>>  drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c         |  6 +--
>>  drivers/gpu/drm/amd/amdgpu/amdgpu_kms.c         |  2 +-
>>  drivers/gpu/drm/drm_auth.c                      |  9 ++--
>>  drivers/gpu/drm/drm_connector.c                 | 10 +++--
>>  drivers/gpu/drm/drm_context.c                   | 20 +++++----
>>  drivers/gpu/drm/drm_dp_aux_dev.c                | 11 ++---
>>  drivers/gpu/drm/drm_drv.c                       |  6 ++-
>>  drivers/gpu/drm/drm_gem.c                       | 19 +++++----
>>  drivers/gpu/drm/drm_info.c                      |  2 +-
>>  drivers/gpu/drm/drm_mode_object.c               | 11 +++--
>>  drivers/gpu/drm/drm_syncobj.c                   | 18 +++++---
>>  drivers/gpu/drm/exynos/exynos_drm_ipp.c         | 25 ++++++-----
>>  drivers/gpu/drm/i915/gvt/display.c              |  2 +-
>>  drivers/gpu/drm/i915/gvt/kvmgt.c                |  2 +-
>>  drivers/gpu/drm/i915/gvt/vgpu.c                 |  9 ++--
>>  drivers/gpu/drm/i915/i915_debugfs.c             |  6 +--
>>  drivers/gpu/drm/i915/i915_gem_context.c         |  9 ++--
>>  drivers/gpu/drm/qxl/qxl_cmd.c                   |  8 ++--
>>  drivers/gpu/drm/qxl/qxl_release.c               | 14 +++---
>>  drivers/gpu/drm/sis/sis_mm.c                    |  8 ++--
>>  drivers/gpu/drm/tegra/drm.c                     | 10 +++--
>>  drivers/gpu/drm/tilcdc/tilcdc_slave_compat.c    |  3 +-
>>  drivers/gpu/drm/vgem/vgem_fence.c               | 12 +++---
>>  drivers/gpu/drm/via/via_mm.c                    |  8 ++--
>>  drivers/gpu/drm/virtio/virtgpu_kms.c            |  5 ++-
>>  drivers/gpu/drm/virtio/virtgpu_vq.c             |  5 ++-
>>  drivers/gpu/drm/vmwgfx/vmwgfx_resource.c        |  9 ++--
>>  drivers/i2c/i2c-core-base.c                     | 19 +++++----
>>  drivers/infiniband/core/cm.c                    |  8 ++--
>>  drivers/infiniband/core/cma.c                   | 12 +++---
>>  drivers/infiniband/core/rdma_core.c             |  9 ++--
>>  drivers/infiniband/core/sa_query.c              | 23 +++++-----
>>  drivers/infiniband/core/ucm.c                   |  7 ++-
>>  drivers/infiniband/core/ucma.c                  | 14 ++++--
>>  drivers/infiniband/hw/cxgb3/iwch.c              |  4 +-
>>  drivers/infiniband/hw/cxgb3/iwch.h              |  4 +-
>>  drivers/infiniband/hw/cxgb4/device.c            | 18 ++++----
>>  drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |  4 +-
>>  drivers/infiniband/hw/hfi1/init.c               |  9 ++--
>>  drivers/infiniband/hw/hfi1/vnic_main.c          |  6 +--
>>  drivers/infiniband/hw/mlx4/cm.c                 | 13 +++---
>>  drivers/infiniband/hw/ocrdma/ocrdma_main.c      |  7 ++-
>>  drivers/infiniband/hw/qib/qib_init.c            |  9 ++--
>>  drivers/infiniband/ulp/opa_vnic/opa_vnic_vema.c | 10 ++---
>>  drivers/iommu/intel-svm.c                       |  9 ++--
>>  drivers/md/dm.c                                 | 13 +++---
>>  drivers/memstick/core/memstick.c                | 10 +++--
>>  drivers/memstick/core/ms_block.c                |  9 ++--
>>  drivers/memstick/core/mspro_block.c             | 12 ++++--
>>  drivers/mfd/rtsx_pcr.c                          |  9 ++--
>>  drivers/misc/c2port/core.c                      |  7 +--
>>  drivers/misc/cxl/context.c                      |  8 ++--
>>  drivers/misc/cxl/main.c                         | 15 ++++---
>>  drivers/misc/mei/main.c                         |  8 ++--
>>  drivers/misc/mic/scif/scif_api.c                | 11 ++---
>>  drivers/misc/mic/scif/scif_ports.c              | 18 ++++----
>>  drivers/misc/tifm_core.c                        |  9 ++--
>>  drivers/mtd/mtdcore.c                           |  9 ++--
>>  drivers/mtd/mtdcore.h                           |  2 +-
>>  drivers/mtd/ubi/block.c                         |  7 ++-
>>  drivers/net/ppp/ppp_generic.c                   | 27 ++++++------
>>  drivers/net/tap.c                               | 10 +++--
>>  drivers/net/wireless/ath/ath10k/htt.h           |  3 +-
>>  drivers/net/wireless/ath/ath10k/htt_tx.c        | 22 ++++++----
>>  drivers/net/wireless/ath/ath10k/mac.c           |  2 +-
>>  drivers/net/wireless/marvell/mwifiex/main.c     | 13 +++---
>>  drivers/net/wireless/marvell/mwifiex/wmm.c      |  2 +-
>>  drivers/of/overlay.c                            | 15 +++----
>>  drivers/of/unittest.c                           | 25 ++++++-----
>>  drivers/power/supply/bq2415x_charger.c          | 16 +++----
>>  drivers/power/supply/bq27xxx_battery_i2c.c      | 15 ++++---
>>  drivers/power/supply/ds2782_battery.c           |  9 ++--
>>  drivers/powercap/powercap_sys.c                 |  8 ++--
>>  drivers/pps/pps.c                               | 10 +++--
>>  drivers/rapidio/rio_cm.c                        | 17 ++++----
>>  drivers/remoteproc/remoteproc_core.c            |  8 ++--
>>  drivers/rpmsg/virtio_rpmsg_bus.c                |  8 ++--
>>  drivers/scsi/bfa/bfad_im.c                      |  8 ++--
>>  drivers/scsi/ch.c                               |  8 ++--
>>  drivers/scsi/lpfc/lpfc_crtn.h                   |  2 +-
>>  drivers/scsi/lpfc/lpfc_init.c                   | 11 +++--
>>  drivers/scsi/lpfc/lpfc_vport.c                  |  8 ++--
>>  drivers/scsi/sg.c                               | 10 +++--
>>  drivers/scsi/st.c                               |  8 ++--
>>  drivers/staging/greybus/uart.c                  | 22 +++++-----
>>  drivers/staging/unisys/visorhba/visorhba_main.c |  7 +--
>>  drivers/target/iscsi/iscsi_target.c             |  7 +--
>>  drivers/target/iscsi/iscsi_target_login.c       |  9 ++--
>>  drivers/target/target_core_device.c             |  9 ++--
>>  drivers/target/target_core_user.c               | 13 +++---
>>  drivers/tee/tee_shm.c                           |  8 ++--
>>  drivers/uio/uio.c                               |  9 ++--
>>  drivers/usb/class/cdc-acm.c                     | 24 ++++++-----
>>  drivers/usb/core/devices.c                      |  2 +-
>>  drivers/usb/core/hcd.c                          |  7 +--
>>  drivers/usb/mon/mon_main.c                      |  3 +-
>>  drivers/usb/serial/usb-serial.c                 | 11 ++---
>>  drivers/vfio/vfio.c                             | 15 ++++---
>>  fs/dlm/lock.c                                   |  9 ++--
>>  fs/dlm/lockspace.c                              |  6 +--
>>  fs/dlm/recover.c                                | 10 ++---
>>  fs/nfs/nfs4client.c                             |  9 ++--
>>  fs/nfsd/nfs4state.c                             |  8 ++--
>>  fs/notify/inotify/inotify_fsnotify.c            |  4 +-
>>  fs/notify/inotify/inotify_user.c                |  9 ++--
>>  fs/ocfs2/cluster/tcp.c                          | 10 +++--
>>  include/linux/idr.h                             | 26 +++++------
>>  include/linux/of.h                              |  4 +-
>>  include/linux/radix-tree.h                      |  2 +-
>>  include/net/9p/9p.h                             |  2 +-
>>  ipc/msg.c                                       |  2 +-
>>  ipc/sem.c                                       |  2 +-
>>  ipc/shm.c                                       |  4 +-
>>  ipc/util.c                                      | 17 ++++----
>>  kernel/bpf/syscall.c                            | 20 +++++----
>>  kernel/cgroup/cgroup.c                          | 57 +++++++++++++++----------
>>  kernel/events/core.c                            | 10 ++---
>>  kernel/workqueue.c                              | 15 ++++---
>>  lib/idr.c                                       | 38 ++++++++++-------
>>  lib/radix-tree.c                                |  5 ++-
>>  mm/memcontrol.c                                 | 11 +++--
>>  net/9p/client.c                                 | 17 ++++----
>>  net/9p/util.c                                   | 14 +++---
>>  net/core/net_namespace.c                        | 23 +++++-----
>>  net/mac80211/cfg.c                              | 23 +++++-----
>>  net/mac80211/iface.c                            |  3 +-
>>  net/mac80211/main.c                             |  2 +-
>>  net/mac80211/tx.c                               |  7 +--
>>  net/mac80211/util.c                             |  3 +-
>>  net/netlink/genetlink.c                         | 18 ++++----
>>  net/qrtr/qrtr.c                                 | 21 +++++----
>>  net/rxrpc/conn_client.c                         | 15 ++++---
>>  net/sctp/associola.c                            |  8 ++--
>>  net/tipc/server.c                               |  7 +--
>>  153 files changed, 956 insertions(+), 736 deletions(-)
>
>
>This is insane
>
>Have you considered switching the pathological hash table in net/sched
>into lib/rhashtable.c ?

rhashtable is unnecesary big hammer for this. IDR is nice fit for
this purpose.


>
>Patch would be limited to networking tree.
>
>
>
