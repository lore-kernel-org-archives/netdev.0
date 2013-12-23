From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: [PATCH 01/21] net: slight optimization of addr
 compare for some modules
Date: Mon, 23 Dec 2013 10:08:40 -0800
Message-ID: <20131223100840.000014a5@unknown>
References: <52B7C590.7070708@huawei.com>
	<52B870E5.3020708@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ding Tianhong <dingtianhong@huawei.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <52B870E5.3020708@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 23 Dec 2013 09:20:37 -0800
Alexander Duyck <alexander.h.duyck@intel.com> wrote:

> On 12/22/2013 09:09 PM, Ding Tianhong wrote:
> > Use the recently added and possibly more efficient
> > ether_addr_equal_unaligned to instead of memcmp.
> >
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: netdev@vger.kernel.org
> > Cc: linux-kernel@vger.kernel.org
> > Cc: e1000-devel@lists.sourceforge.net
> > Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> > ---
> >  drivers/net/bonding/bond_3ad.c                        |  2 +-
> >  drivers/net/ethernet/3com/3c509.c                     |  3 +--
> >  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c        | 10
> > ++++------ drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c     |
> > 2 +- drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c      |  2 +-
> >  drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c    |  2 +-
> >  drivers/net/ethernet/chelsio/cxgb3/l2t.c              |  2 +-
> >  drivers/net/ethernet/cisco/enic/enic_pp.c             |  2 +-
> >  drivers/net/ethernet/emulex/benet/be_main.c           |  2 +-
> >  drivers/net/ethernet/intel/igbvf/netdev.c             |  2 +-
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c        |  3 +--
> >  drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |  4 ++--
> >  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  2 +-
> >  drivers/net/ethernet/micrel/ksz884x.c                 |  9
> > ++++----- drivers/net/ethernet/neterion/vxge/vxge-main.c        |
> > 2 +- drivers/net/ethernet/packetengines/yellowfin.c        |  8
> > ++------ drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c    |  2
> > +- drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c        |  4 ++--
> >  drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c        |  4 ++--
> >  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |  4 ++--
> >  drivers/net/ethernet/renesas/sh_eth.c                 |  2 +-
> >  drivers/net/ethernet/seeq/sgiseeq.c                   |  2 +-
> >  drivers/net/ethernet/sun/sunvnet.c                    |  2 +-
> >  drivers/net/ethernet/ti/cpsw_ale.c                    |  2 +-
> >  drivers/net/fddi/skfp/fplustm.c                       |  3 ++-
> >  drivers/net/plip/plip.c                               |  2 +-
> >  net/caif/cfrfml.c                                     |  2 +-
> >  27 files changed, 39 insertions(+), 47 deletions(-)
> 
> What is it you are trying to optimize for, size or speed?  Most of
> these calls are in slow path.  Replacing the memcmp with an inline
> operation may provide little to no gain in terms of speed and in many
> cases as you might actually be increasing the resultant driver size.
> 
> Also I would recommend reviewing the addresses you are comparing.  It
> is likely that you could use ether_addr_equal or compare_ether_addr
> in many cases as I suspect a number of spots are using 16b aligned
> MAC addresses for both operands.

User ether_addr_equal.  compare_ether_addr was recently removed from
the upstream kernel - as I discovered to my chagrin late one
recent Friday evening while trying to get a build done.

- Greg

> 
> Thanks,
> 
> Alex
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
