From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] RFC: "mlx4" drivers for Mellanox ConnectX HCAs
Date: Mon, 09 Apr 2007 21:17:30 -0700
Message-ID: <adawt0k3lt1.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: general@lists.openfabrics.org, linux-kernel@vger.kernel.org,
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

I'd like to announce preliminary versions of a set of "mlx4" drivers
for Mellanox's new ConnectX InfiniBand/10 gigabit ethernet adapters.
(These are Mellanox's 4th generation of adapters, hence the mlx4 name)
Because these adapters can operate as both an ethernet NIC and an
InfiniBand HCA (at the same time!), the driver is split up into three
pieces:

    mlx4_core: Basic support for hardware, managing resources, sending
      commands to firmware, etc.  Lives in drivers/net/mlx4 (so that
      it gets built in a natural way for ethernet support, even if
      CONFIG_INFINIBAND=n) and exports its API in include/linux/mlx4.

    mlx4_ib: InfiniBand HCA driver, sits between the IB midlayer and
      mlx4_core.  Lives in drivers/infiniband/hw/mlx4.

    mlx4_eth: Ethernet NIC driver, sits between networking stack and
      mlx4_core.  Also lives in drivers/net/mlx4.  This is just a stub
      right now, because firmware support for ethernet mode is still
      too immature.

In fact, the ConnectX hardware has support for fibre channel stuff
too, so in the future there may also be an FC HBA driver layered on
top of mlx4_core as well.

I will post a full set of patches for review via email once I've had a
chance to clean things up and split things into reasonable sized
chunks (the full patch is > 300 KB right now), but for those who are
interested, you can grab the connectx branch of my infiniband.git tree:

    git://git.kernel.org/pub/scm/linux/kernel/git/roland/infiniband.git connectx

I've also put this code in my for-mm branch, so it should appear in
the next -mm kernel whenever Andrew has time to get one out.

Any and all comments are appreciated; my current plan is to merge the
mlx4_core and mlx4_ib drivers for 2.6.22, and I hope that mlx4_eth
will be ready for 2.6.23.

I've tried to flag areas that are not fully implemented or still need
work, and there are quite a few places that need cleanup, but the
driver is at least able to run IP-over-InfiniBand and some basic
userspace direct access tests.

Speaking of direct access, a preliminary version of a userspace driver
that works with libibverbs is available from:

    git://git.kernel.org/pub/scm/libs/infiniband/libmlx4.git


Thanks to the crew at Mellanox for lots of help with sample code and
debugging, as well as early access to the hardware!
