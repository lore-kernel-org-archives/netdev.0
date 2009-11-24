From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Tue, 24 Nov 2009 14:11:22 +1100
Message-ID: <20091124141122.63e81c55.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/e1000e/ich8lan.c between commit
818f33313caab9be2a10458500dbed4a88c1b334 ("e1000e: do not initiate
autonegotiation during OEM configuration") from the net-current tree and
commit 94d8186a693284344ee5cb9734086c7a2370241a ("e1000e: cleanup ops
function pointers") from the net tree.

Just context changes. I fixed it up (see below) and can carry the fix for
a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/e1000e/ich8lan.c
index eff3f47,568bb25..0000000
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@@ -1118,12 -1110,11 +1110,12 @@@ static s32 e1000_oem_bits_config_ich8la
  			oem_reg |= HV_OEM_BITS_LPLU;
  	}
  	/* Restart auto-neg to activate the bits */
 -	oem_reg |= HV_OEM_BITS_RESTART_AN;
 +	if (!e1000_check_reset_block(hw))
 +		oem_reg |= HV_OEM_BITS_RESTART_AN;
- 	ret_val = hw->phy.ops.write_phy_reg_locked(hw, HV_OEM_BITS, oem_reg);
+ 	ret_val = hw->phy.ops.write_reg_locked(hw, HV_OEM_BITS, oem_reg);
  
  out:
- 	hw->phy.ops.release_phy(hw);
+ 	hw->phy.ops.release(hw);
  
  	return ret_val;
  }
