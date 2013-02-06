From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 0/2] fix kernel crash with macvtap on top of
	LRO
Date: Thu, 7 Feb 2013 01:02:38 +0200
Message-ID: <cover.1360191528.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, e1000-devel@lists.sourceforge.net,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Sony Chacko <sony.chacko@qlogic.com>, linux-driver@qlogic.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

At the moment, macvtap crashes are observed if macvtap is attached
to an interface with LRO enabled.
The crash in question is BUG() in macvtap_skb_to_vnet_hdr.
This happens because several drivers set gso_size but not gso_type
in incoming skbs.
The following patches fix this for
Additionally, cbf1de72324a8105ddcc3d9ce9acbc613faea17e is required
to fix this for broadcom - would it make sense to cherry-pick
this patch into 3.8?

I tested that the patch fixes the crash for ixgbe but
don't have qlogic hardware to fix.  I also only tested TCP.

Feedback wellcome.

Michael S. Tsirkin (2):
  ixgbe: fix gso type
  qlcnic: set gso_type

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 8 ++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c | 7 ++++++-
 2 files changed, 12 insertions(+), 3 deletions(-)

-- 
MST

------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
