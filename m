From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PULL] vhost: cleanups and fixes
Date: Thu, 2 May 2013 22:33:09 +0300
Message-ID: <20130502193309.GC16031@redhat.com>
References: <20130502105353.GA24655@redhat.com>
 <1367520929.23900.114.camel@haakon3.risingtidesystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	asias@redhat.com, target-devel <target-devel@vger.kernel.org>,
	torvalds@linux-foundation.org
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1367520929.23900.114.camel@haakon3.risingtidesystems.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 02, 2013 at 11:55:29AM -0700, Nicholas A. Bellinger wrote:
> On Thu, 2013-05-02 at 13:53 +0300, Michael S. Tsirkin wrote:
> > The following changes since commit c39904a0ac22cf05f5f44226457f6da0fe65457e:
> > 
> >   Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next (2013-04-26 23:33:41 -0400)
> > 
> > are available in the git repository at:
> > 
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus
> > 
> > for you to fetch changes up to 181c04a357bb791587c55a99362c2fdde2c64f18:
> > 
> >   vhost_scsi: module rename (2013-05-02 13:40:22 +0300)
> > 
> > ----------------------------------------------------------------
> > vhost: cleanups and fixes for 3.10
> > 
> > Here are vhost cleanups and fixes by Asias He and myself.
> > They affect both vhost-net and vhost-scsi devices.
> > They also *depend* on both net-next and target-pending,
> > where the net and target commits these changes depend on
> > are already merged.
> > So merging through the common vhost tree.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > 
> 
> Just FYI, if this PULL request is going to Linus directly, you'll
> probably want to rebase a branch atop a more recent mainline HEAD in
> order to produce a correct diffstat, instead of the one including the
> target-pending/for-next-merge merge commit below..
> 
> Then again, asking Linus what he prefers for this type of scenario never
> hurt anyone either.  ;)
> 
> --nab


Oops I did something wrong and Linus was not on the To list at all :(
I'll have to repost.
I prefer not rebasing, will play with git to see why
does request-pull get me a wrong diffstat and how
to trick it into doing the right thing.
Maybe merging my branch into master will do this.


> > ----------------------------------------------------------------
> > Asias He (3):
> >       vhost: Allow device specific fields per vq
> >       tcm_vhost: Wait for pending requests in vhost_scsi_flush()
> >       vhost: move vhost-net zerocopy fields to net.c
> > 
> > Michael S. Tsirkin (8):
> >       Merge branch 'for-next-merge' of git://git.kernel.org/.../nab/target-pending into vhost-net-next
> >       tcm_vhost: document inflight ref-counting use
> >       vhost: move per-vq net specific fields out to net
> >       tcm_vhost: remove virtio-net.h dependency
> >       vhost: fix error handling in RESET_OWNER ioctl
> >       vhost: src file renames
> >       tcm_vhost: header split up
> >       vhost_scsi: module rename
> > 
> >  drivers/infiniband/Kconfig                     |    1 +
> >  drivers/infiniband/Makefile                    |    1 +
> >  drivers/infiniband/ulp/isert/Kconfig           |    5 +
> >  drivers/infiniband/ulp/isert/Makefile          |    2 +
> >  drivers/infiniband/ulp/isert/ib_isert.c        | 2281 ++++++++++++++++++++++++
> >  drivers/infiniband/ulp/isert/ib_isert.h        |  138 ++
> >  drivers/infiniband/ulp/isert/isert_proto.h     |   47 +
> >  drivers/scsi/qla2xxx/qla_target.c              |   19 -
> >  drivers/scsi/qla2xxx/qla_target.h              |    1 -
> >  drivers/target/iscsi/Makefile                  |    3 +-
> >  drivers/target/iscsi/iscsi_target.c            | 1184 +++++++-----
> >  drivers/target/iscsi/iscsi_target.h            |    3 +-
> >  drivers/target/iscsi/iscsi_target_auth.c       |   28 +-
> >  drivers/target/iscsi/iscsi_target_configfs.c   |   98 +-
> >  drivers/target/iscsi/iscsi_target_core.h       |   26 +-
> >  drivers/target/iscsi/iscsi_target_device.c     |    7 +-
> >  drivers/target/iscsi/iscsi_target_erl1.c       |   13 +-
> >  drivers/target/iscsi/iscsi_target_login.c      |  472 +++--
> >  drivers/target/iscsi/iscsi_target_login.h      |    6 +
> >  drivers/target/iscsi/iscsi_target_nego.c       |  194 +-
> >  drivers/target/iscsi/iscsi_target_nego.h       |   11 +-
> >  drivers/target/iscsi/iscsi_target_parameters.c |   87 +-
> >  drivers/target/iscsi/iscsi_target_parameters.h |   16 +-
> >  drivers/target/iscsi/iscsi_target_tmr.c        |    4 +-
> >  drivers/target/iscsi/iscsi_target_tpg.c        |    6 +-
> >  drivers/target/iscsi/iscsi_target_transport.c  |   55 +
> >  drivers/target/iscsi/iscsi_target_util.c       |   53 +-
> >  drivers/target/iscsi/iscsi_target_util.h       |    1 +
> >  drivers/target/target_core_file.c              |  122 +-
> >  drivers/target/target_core_iblock.c            |  108 +-
> >  drivers/target/target_core_sbc.c               |   85 +
> >  drivers/target/target_core_transport.c         |   13 +-
> >  drivers/target/tcm_fc/tfc_io.c                 |    9 +-
> >  drivers/target/tcm_fc/tfc_sess.c               |    9 +-
> >  drivers/vhost/Kconfig                          |   10 +-
> >  drivers/vhost/Kconfig.tcm                      |    6 -
> >  drivers/vhost/Makefile                         |    3 +-
> >  drivers/vhost/net.c                            |  255 ++-
> >  drivers/vhost/{tcm_vhost.c => scsi.c}          |  507 +++++-
> >  drivers/vhost/tcm_vhost.h                      |  115 --
> >  drivers/vhost/test.c                           |    9 +-
> >  drivers/vhost/vhost.c                          |  153 +-
> >  drivers/vhost/vhost.h                          |   32 +-
> >  include/target/iscsi/iscsi_transport.h         |   83 +
> >  include/target/target_core_backend.h           |    4 +
> >  include/target/target_core_fabric.h            |    2 +-
> >  include/uapi/linux/vhost.h                     |   28 +
> >  47 files changed, 4985 insertions(+), 1330 deletions(-)
> >  create mode 100644 drivers/infiniband/ulp/isert/Kconfig
> >  create mode 100644 drivers/infiniband/ulp/isert/Makefile
> >  create mode 100644 drivers/infiniband/ulp/isert/ib_isert.c
> >  create mode 100644 drivers/infiniband/ulp/isert/ib_isert.h
> >  create mode 100644 drivers/infiniband/ulp/isert/isert_proto.h
> >  create mode 100644 drivers/target/iscsi/iscsi_target_transport.c
> >  delete mode 100644 drivers/vhost/Kconfig.tcm
> >  rename drivers/vhost/{tcm_vhost.c => scsi.c} (76%)
> >  delete mode 100644 drivers/vhost/tcm_vhost.h
> >  create mode 100644 include/target/iscsi/iscsi_transport.h
> 
