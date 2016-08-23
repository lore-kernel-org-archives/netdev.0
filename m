From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [for-next V3 00/15][PULL request] Mellanox mlx5 core driver
 updates 2016-08-20
Date: Tue, 23 Aug 2016 19:10:53 +0300
Message-ID: <CALzJLG8=+D2a-dtaTMJWu_95Mdroh51Ph3dGths1eO3spzp58g@mail.gmail.com>
References: <1471942157-9131-1-git-send-email-saeedm@mellanox.com> <1a97f16d-5a0a-cb06-6e5c-1b6f9fa7c609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1a97f16d-5a0a-cb06-6e5c-1b6f9fa7c609-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 23, 2016 at 6:57 PM, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 8/23/2016 4:49 AM, Saeed Mahameed wrote:
>> Hi Dave and Doug,
>>
>> This series contains several low level and API updates for mlx5 core
>> commands interface and mlx5_ifc.h to be shared as base code for net-next and
>> rdma mlx5 4.9 submissions.
>>
>> From Saeed, ten patches that refactors old layouts of firmware commands which
>> were manually generated before we introduced the mlx5_ifc, now all of the firmware
>> commands inbox/outbox layouts moved to use mlx5_ifc and we remove the old
>> manually generated structures.
>
> These all looked fine to me.
>
>> Plus to those ten patches, we add two patches
>> that unifies mlx5 commands execution interface and improve the driver log messages
>> in that area.
>
> These are the patches that made my eyes want to bleed.  But, since it's
> all changes to the mailbox commands being sent to your device, they are
> easy to verify operationally, so I only gave these a cursory review and
> expect if any of your commands broke because of this you'll be
> submitting fixes ASAP.
>

Thanks Doug for your review those patches already passed all kinds of
our internal regression testings.
What is nice about those patches is that they remove  ~1K  LOC from
driver and unify the command interface.

>
>> From Hadar and Ilya, added the needed hardware bits and infrastructure for
>> minimum inline headers setting and encap/decap commands and capabilities,
>> needed for E-Switch offloads.
>
> These looked fine to me, but aren't really in the RDMA area anyway.
>
>> This series applies on top latest net-next and rdma/master, and smoothly merges with
>> the latest "Mellanox 100G mlx5 fixes 2016-08-16" series already applied into net branch.
>>
>> The following changes since commit 29b4817d4018df78086157ea3a55c1d9424a7cfc:
>>     Linux 4.8-rc1
>>
>> are available in the git repository at:
>>     git://git.kernel.org/pub/scm/linux/kernel/git/leon/linux-rdma.git tags/shared-for-4.9-1
>
> I've pulled these into a local branch and they look fine.  Once Dave
> gives his ack/nack, we'll go from there.
>
>> for you to fetch changes up to 575ddf5888eaf8f271cb3df7b0806cb2db2c333a:
>>     net/mlx5: Introduce alloc_encap and dealloc_encap commands
>>
>> Changes since V2 and V1:
>>     - Reduce the number of patches and changed the cover letter respectively.
>>
>> Thanks,
>> Saeed & Leon.
>>
>> Hadar Hen Zion (2):
>>   net/mlx5: Enable setting minimum inline header mode for VFs
>>   net/mlx5: Update mlx5_ifc.h for vxlan encap/decap
>>
>> Ilya Lesokhin (1):
>>   net/mlx5: Introduce alloc_encap and dealloc_encap commands
>>
>> Saeed Mahameed (12):
>>   net/mlx5: Init/Teardown hca commands via mlx5 ifc
>>   net/mlx5: Access register and MAD IFC commands via mlx5 ifc
>>   net/mlx5: PD and UAR commands via mlx5 ifc
>>   net/mlx5: MCG commands via mlx5 ifc
>>   net/mlx5: Pages management commands via mlx5 ifc
>>   net/mlx5: EQ commands via mlx5 ifc
>>   {net,IB}/mlx5: CQ commands via mlx5 ifc
>>   {net,IB}/mlx5: MKey/PSV commands via mlx5 ifc
>>   {net,IB}/mlx5: QP/XRCD commands via mlx5 ifc
>>   {net,IB}/mlx5: Modify QP commands via mlx5 ifc
>>   net/mlx5: Unify and improve command interface
>>   net/mlx5: Improve driver log messages
>>
>>  drivers/infiniband/hw/mlx5/cq.c                    | 110 +++---
>>  drivers/infiniband/hw/mlx5/main.c                  |  10 +-
>>  drivers/infiniband/hw/mlx5/mlx5_ib.h               |   2 +-
>>  drivers/infiniband/hw/mlx5/mr.c                    | 184 +++++----
>>  drivers/infiniband/hw/mlx5/qp.c                    | 189 ++++-----
>>  drivers/net/ethernet/mellanox/mlx5/core/cmd.c      | 261 +++++++------
>>  drivers/net/ethernet/mellanox/mlx5/core/cq.c       | 109 ++----
>>  drivers/net/ethernet/mellanox/mlx5/core/debugfs.c  |  50 +--
>>  .../net/ethernet/mellanox/mlx5/core/en_common.c    |  23 +-
>>  .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   3 +-
>>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  47 +--
>>  drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |   4 +-
>>  drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  80 ++--
>>  drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  98 ++---
>>  drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   | 178 ++++-----
>>  drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |   7 +
>>  drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  18 +-
>>  drivers/net/ethernet/mellanox/mlx5/core/fw.c       |  43 +--
>>  drivers/net/ethernet/mellanox/mlx5/core/mad.c      |  41 +-
>>  drivers/net/ethernet/mellanox/mlx5/core/main.c     |  91 ++---
>>  drivers/net/ethernet/mellanox/mlx5/core/mcg.c      |  72 +---
>>  .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  17 +-
>>  drivers/net/ethernet/mellanox/mlx5/core/mr.c       | 189 ++++-----
>>  .../net/ethernet/mellanox/mlx5/core/pagealloc.c    | 156 +++-----
>>  drivers/net/ethernet/mellanox/mlx5/core/pd.c       |  61 +--
>>  drivers/net/ethernet/mellanox/mlx5/core/port.c     | 149 +++----
>>  drivers/net/ethernet/mellanox/mlx5/core/qp.c       | 299 ++++++++------
>>  drivers/net/ethernet/mellanox/mlx5/core/rl.c       |  11 +-
>>  drivers/net/ethernet/mellanox/mlx5/core/sriov.c    |   7 +-
>>  drivers/net/ethernet/mellanox/mlx5/core/srq.c      |  49 +--
>>  drivers/net/ethernet/mellanox/mlx5/core/transobj.c | 183 +++------
>>  drivers/net/ethernet/mellanox/mlx5/core/uar.c      |  67 +---
>>  drivers/net/ethernet/mellanox/mlx5/core/vport.c    |  94 ++---
>>  drivers/net/ethernet/mellanox/mlx5/core/vxlan.c    |  29 +-
>>  include/linux/mlx5/cq.h                            |   6 +-
>>  include/linux/mlx5/device.h                        | 429 +--------------------
>>  include/linux/mlx5/driver.h                        |  20 +-
>>  include/linux/mlx5/mlx5_ifc.h                      | 116 +++++-
>>  include/linux/mlx5/qp.h                            | 128 +-----
>>  include/linux/mlx5/vport.h                         |   2 +
>>  40 files changed, 1390 insertions(+), 2242 deletions(-)
>>
>
>
> --
> Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>     GPG Key ID: 0E572FDD
>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
