From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: ixgbe: Unsupported SFP+ modules on 10Gbit/s
	X520-DA2 NIC?
Date: Wed, 18 Jan 2012 23:19:20 +0100
Message-ID: <1326925160.2795.45.camel@probook>
References: <1326886258.19261.25.camel@probook>
	<20120118091351.000052fc@unknown>  <m3d3ag7ki8.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <m3d3ag7ki8.fsf@ursa.amorsen.dk>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2012-01-18 at 22:45 +0100, Benny Amorsen wrote:
> Jesse Brandeburg <jesse.brandeburg@intel.com> writes:
> 
> > For X520 adapters, the documentation[1] states that which SFP+
> > adapters are/are not supported.  Direct attach cables are also
> > supported.
> >
> > [1] http://www.intel.com/support/network/adapter/pro100/sb/CS-030612.htm
> 
> I can't believe that locked optics have now arrived on commodity
> hardware. I have been trying to migrate to all-Intel networking at work;
> that effort is certainly on hold now.

I cannot understand why Intel are pulling a stunt like this! :-(

I have read the code, and the limitation comes from a EEPROM setting on
the NIC, see define "IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP 0x1".

Here is a (untested) patch I believe removes the limitation in the
driver:


[PATCH] ixgbe: Always allow any SFP+ regardless of EEPROM setting.

Intel are trying to limit which SFP's we can use in our NICs.
We don't like this practices in the Linux Kernel.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 7cf1e1f..2b13083 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -1061,6 +1061,8 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 		}
 
 		hw->mac.ops.get_device_caps(hw, &enforce_sfp);
+		/* Hack: Always allow any SFP regardless of EEPROM setting */
+		enforce_sfp |= IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP;
 		if (!(enforce_sfp & IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP) &&
 		    !((hw->phy.sfp_type == ixgbe_sfp_type_1g_cu_core0) ||
 		      (hw->phy.sfp_type == ixgbe_sfp_type_1g_cu_core1))) {



------------------------------------------------------------------------------
Keep Your Developer Skills Current with LearnDevNow!
The most comprehensive online learning library for Microsoft developers
is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, MVC3,
Metro Style Apps, more. Free future releases when you subscribe now!
http://p.sf.net/sfu/learndevnow-d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
