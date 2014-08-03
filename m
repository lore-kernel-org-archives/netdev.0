From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 1/2] e1000e: fix trivial kernel doc
	typos
Date: Sat,  2 Aug 2014 20:37:10 -0600
Message-ID: <1407026820-26552-2-git-send-email-mysctp@gmail.com>
References: <1407026820-26552-1-git-send-email-mysctp@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Linux NICS <linux.nics@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	<aaron.f.brown@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1407026820-26552-1-git-send-email-mysctp@gmail.com>
In-Reply-To: <1407026820-26552-1-git-send-email-mysctp@gmail.com>
References: <1407026820-26552-1-git-send-email-mysctp@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The macro E1000_success is meant to be E1000_SUCCESS. As the return
statement in the function is good as is, let's simply correct the
comment for this trivial matter.

Additionally E1000_ERR_HOST_INTERFACE_COMMAND is supposed to be
-E1000_ERR_HOST_INTERFACE_COMMAND.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 drivers/net/ethernet/intel/e1000e/manage.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/manage.c b/drivers/net/ethernet/intel/e1000e/manage.c
index 58856032298d..e156664d5ba1 100644
--- a/drivers/net/ethernet/intel/e1000e/manage.c
+++ b/drivers/net/ethernet/intel/e1000e/manage.c
@@ -14,73 +14,73 @@
  * the file called "COPYING".
  *
  * Contact Information:
  * Linux NICS <linux.nics@intel.com>
  * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
  * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
  */
 
 #include "e1000.h"
 
 /**
  *  e1000_calculate_checksum - Calculate checksum for buffer
  *  @buffer: pointer to EEPROM
  *  @length: size of EEPROM to calculate a checksum for
  *
  *  Calculates the checksum for some buffer on a specified length.  The
  *  checksum calculated is returned.
  **/
 static u8 e1000_calculate_checksum(u8 *buffer, u32 length)
 {
 	u32 i;
 	u8 sum = 0;
 
 	if (!buffer)
 		return 0;
 
 	for (i = 0; i < length; i++)
 		sum += buffer[i];
 
 	return (u8)(0 - sum);
 }
 
 /**
  *  e1000_mng_enable_host_if - Checks host interface is enabled
  *  @hw: pointer to the HW structure
  *
- *  Returns E1000_success upon success, else E1000_ERR_HOST_INTERFACE_COMMAND
+ *  Returns 0 upon success, else -E1000_ERR_HOST_INTERFACE_COMMAND
  *
  *  This function checks whether the HOST IF is enabled for command operation
  *  and also checks whether the previous command is completed.  It busy waits
  *  in case of previous command is not completed.
  **/
 static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
 {
 	u32 hicr;
 	u8 i;
 
 	if (!hw->mac.arc_subsystem_valid) {
 		e_dbg("ARC subsystem not valid.\n");
 		return -E1000_ERR_HOST_INTERFACE_COMMAND;
 	}
 
 	/* Check that the host interface is enabled. */
 	hicr = er32(HICR);
 	if (!(hicr & E1000_HICR_EN)) {
 		e_dbg("E1000_HOST_EN bit disabled.\n");
 		return -E1000_ERR_HOST_INTERFACE_COMMAND;
 	}
 	/* check the previous command is completed */
 	for (i = 0; i < E1000_MNG_DHCP_COMMAND_TIMEOUT; i++) {
 		hicr = er32(HICR);
 		if (!(hicr & E1000_HICR_C))
 			break;
 		mdelay(1);
 	}
 
 	if (i == E1000_MNG_DHCP_COMMAND_TIMEOUT) {
 		e_dbg("Previous command timeout failed .\n");
 		return -E1000_ERR_HOST_INTERFACE_COMMAND;
 	}
 
 	return 0;
 }

------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
