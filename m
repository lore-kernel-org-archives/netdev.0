From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Tue, 24 Nov 2009 14:11:31 +1100
Message-ID: <20091124141131.49b37eec.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757907AbZKXDLc@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/e1000e/phy.c between commit
189983d469c6d98e64ddfb9f9ce76725cb082ee5 ("e1000e: remove unnecessary
82577 workaround causing link issues") from the net-current tree and
commit 94d8186a693284344ee5cb9734086c7a2370241a ("e1000e: cleanup ops
function pointers") from the net tree.

I fixed it up (see below) and can carry the fix for a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

diff --cc drivers/net/e1000e/phy.c
index 85f955f,99d53fa..0000000
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@@ -658,7 -659,16 +658,7 @@@ s32 e1000_copper_link_setup_82577(struc
  	/* Enable downshift */
  	phy_data |= I82577_CFG_ENABLE_DOWNSHIFT;
  
- 	ret_val = phy->ops.write_phy_reg(hw, I82577_CFG_REG, phy_data);
+ 	ret_val = phy->ops.write_reg(hw, I82577_CFG_REG, phy_data);
 -	if (ret_val)
 -		goto out;
 -
 -	/* Set number of link attempts before downshift */
 -	ret_val = phy->ops.read_reg(hw, I82577_CTRL_REG, &phy_data);
 -	if (ret_val)
 -		goto out;
 -	phy_data &= ~I82577_CTRL_DOWNSHIFT_MASK;
 -	ret_val = phy->ops.write_reg(hw, I82577_CTRL_REG, phy_data);
  
  out:
  	return ret_val;
@@@ -2667,10 -2678,10 +2667,10 @@@ static s32 __e1000_read_phy_reg_hv(stru
  out:
  	/* Revert to MDIO fast mode, if applicable */
  	if ((hw->phy.type == e1000_phy_82577) && in_slow_mode)
 -		ret_val = e1000_set_mdio_slow_mode_hv(hw, false);
 +		ret_val |= e1000_set_mdio_slow_mode_hv(hw, false);
  
  	if (!locked)
- 		hw->phy.ops.release_phy(hw);
+ 		hw->phy.ops.release(hw);
  
  	return ret_val;
  }
@@@ -2793,10 -2805,10 +2793,10 @@@ static s32 __e1000_write_phy_reg_hv(str
  out:
  	/* Revert to MDIO fast mode, if applicable */
  	if ((hw->phy.type == e1000_phy_82577) && in_slow_mode)
 -		ret_val = e1000_set_mdio_slow_mode_hv(hw, false);
 +		ret_val |= e1000_set_mdio_slow_mode_hv(hw, false);
  
  	if (!locked)
- 		hw->phy.ops.release_phy(hw);
+ 		hw->phy.ops.release(hw);
  
  	return ret_val;
  }
