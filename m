From: Joe Perches <joe@perches.com>
Subject: Re: [net-next  06/10] ixgbe: cleanup some log messages
Date: Wed, 28 Aug 2013 09:36:53 -0700
Message-ID: <1377707813.1928.30.camel@joe-AO722>
References: <1377686028-30747-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377686028-30747-7-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377701368.1928.10.camel@joe-AO722>
	 <F6FB0E698C9B3143BDF729DF222866466FD4530B@ORSMSX110.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:48509 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752111Ab3H1Qgy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 12:36:54 -0400
In-Reply-To: <F6FB0E698C9B3143BDF729DF222866466FD4530B@ORSMSX110.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-28 at 16:19 +0000, Skidmore, Donald C wrote:
> > -----Original Message-----
> > From: Joe Perches [mailto:joe@perches.com]
[]
> > At some point it might be nice to remove the remaining bool direct
> > comparisons to true/false
> > 
> > $ git grep -E -n "(==|!=)\s*(true|false)" drivers/net/ethernet/intel
> > drivers/net/ethernet/intel/e1000e/netdev.c:4871:
> > (hw->mac.autoneg == true) &&
> > drivers/net/ethernet/intel/e1000e/phy.c:2651: *  Assumes semaphore is
> > already acquired.  When page_set==true, assumes
> > drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c:763:	if (hw-
> > >phy.reset_disable == false) {
[etc...]
> Thanks for pointing this out Joe. 

Just a bit of code style ocd... ;)

>  I'll [] talk with the e1000e owner about doing it with their driver.

I believe the e1000e driver isn't using a bool
comparison as autoneg is a u8, but it could still use
	hw->mac.autoneg
for consistency with the other tests in the same driver.

Maybe:
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 2fead50..be9c033 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4869,7 +4869,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 			 */
 			if ((hw->phy.type == e1000_phy_igp_3 ||
 			     hw->phy.type == e1000_phy_bm) &&
-			    (hw->mac.autoneg == true) &&
+			    hw->mac.autoneg &&
 			    (adapter->link_speed == SPEED_10 ||
 			     adapter->link_speed == SPEED_100) &&
 			    (adapter->link_duplex == HALF_DUPLEX)) {
