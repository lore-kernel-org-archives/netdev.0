From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] [last RFC] mlx4 (Mellanox ConnectX adapter) InfiniBand
	drivers
Date: Mon, 07 May 2007 19:40:29 -0700
Message-ID: <adaejls597m.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, general@lists.openfabrics.org,
	netdev@vger.kernel.org
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

I've added my InfiniBand drivers for the new Mellanox ConnectX adapter
to what's queued up for 2.6.22 in:

    git://git.kernel.org/pub/scm/linux/kernel/git/roland/infiniband.git for-2.6.22

This is still a new driver, with some things missing and undoubtedly
some bugs and opportunities for cleanup, but I trust myself to keep
improving the driver even after it's upstream.  Unless I hear a good
reason why I shouldn't, I'll ask Linus to pull this tomorrow.

I received no responses to my earlier posts, so I'm not going to spam
everyone with a big patch series again.  But here's the diffstat at
least -- if you want to see details, just pull the git URL above.

commit 0c2f16963d60c30920ee4fb3c900ae29d6ed0f74
Author: Roland Dreier <rolandd@cisco.com>
Date:   Mon May 7 15:48:06 2007 -0700

    IB/mlx4: Add a driver Mellanox ConnectX InfiniBand adapters
    
    Add an InfiniBand driver for Mellanox ConnectX adapters.  Because
    these adapters can also be used as ethernet NICs and Fibre Channel
    HBAs, the driver is split into two modules:
    
      mlx4_core: Handles low-level things like device initialization and
        processing firmware commands.  Also controls resource allocation
        so that the InfiniBand, ethernet and FC functions can share a
        device without stepping on each other.
    
      mlx4_ib: Handles InfiniBand-specific things; plugs into the
        InfiniBand midlayer.
    
    Signed-off-by: Roland Dreier <rolandd@cisco.com>

 drivers/infiniband/Kconfig            |    2 +
 drivers/infiniband/Makefile           |    1 +
 drivers/infiniband/hw/mlx4/Kconfig    |    9 +
 drivers/infiniband/hw/mlx4/Makefile   |    3 +
 drivers/infiniband/hw/mlx4/ah.c       |  100 +++
 drivers/infiniband/hw/mlx4/cq.c       |  525 +++++++++++++
 drivers/infiniband/hw/mlx4/doorbell.c |  216 ++++++
 drivers/infiniband/hw/mlx4/mad.c      |  339 +++++++++
 drivers/infiniband/hw/mlx4/main.c     |  651 +++++++++++++++++
 drivers/infiniband/hw/mlx4/mlx4_ib.h  |  285 ++++++++
 drivers/infiniband/hw/mlx4/mr.c       |  184 +++++
 drivers/infiniband/hw/mlx4/qp.c       | 1294 +++++++++++++++++++++++++++++++++
 drivers/infiniband/hw/mlx4/srq.c      |  334 +++++++++
 drivers/infiniband/hw/mlx4/user.h     |   92 +++
 drivers/net/Kconfig                   |   14 +
 drivers/net/Makefile                  |    1 +
 drivers/net/mlx4/Makefile             |    4 +
 drivers/net/mlx4/alloc.c              |  179 +++++
 drivers/net/mlx4/catas.c              |   70 ++
 drivers/net/mlx4/cmd.c                |  429 +++++++++++
 drivers/net/mlx4/cq.c                 |  254 +++++++
 drivers/net/mlx4/eq.c                 |  696 ++++++++++++++++++
 drivers/net/mlx4/fw.c                 |  775 ++++++++++++++++++++
 drivers/net/mlx4/fw.h                 |  167 +++++
 drivers/net/mlx4/icm.c                |  379 ++++++++++
 drivers/net/mlx4/icm.h                |  135 ++++
 drivers/net/mlx4/intf.c               |  165 +++++
 drivers/net/mlx4/main.c               |  936 ++++++++++++++++++++++++
 drivers/net/mlx4/mcg.c                |  380 ++++++++++
 drivers/net/mlx4/mlx4.h               |  348 +++++++++
 drivers/net/mlx4/mr.c                 |  479 ++++++++++++
 drivers/net/mlx4/pd.c                 |  102 +++
 drivers/net/mlx4/profile.c            |  238 ++++++
 drivers/net/mlx4/qp.c                 |  273 +++++++
 drivers/net/mlx4/reset.c              |  181 +++++
 drivers/net/mlx4/srq.c                |  227 ++++++
 include/linux/mlx4/cmd.h              |  178 +++++
 include/linux/mlx4/cq.h               |  123 ++++
 include/linux/mlx4/device.h           |  331 +++++++++
 include/linux/mlx4/doorbell.h         |   97 +++
 include/linux/mlx4/driver.h           |   59 ++
 include/linux/mlx4/qp.h               |  288 ++++++++
 include/linux/mlx4/srq.h              |   42 ++
 43 files changed, 11585 insertions(+), 0 deletions(-)
