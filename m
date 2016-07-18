From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 18 Jul 2016 11:59:49 +1000
Message-ID: <20160718115949.1e693534@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kiran Patil <kiran.patil@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:60305 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751376AbcGRB7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jul 2016 21:59:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/intel/i40e/i40e_main.c

between commit:

  f6bd09625ba6 ("i40e: enable VSI broadcast promiscuous mode instead of adding broadcast filter")

from the net tree and commit:

  3e25a8f31af1 ("i40e: add hw struct local variable")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/intel/i40e/i40e_main.c
index eb09f60b4984,2b1140563a64..000000000000
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@@ -2152,12 -2165,27 +2172,15 @@@ int i40e_sync_vsi_filters(struct i40e_v
  			if (aq_ret) {
  				retval =
  				i40e_aq_rc_to_posix(aq_ret,
- 						    pf->hw.aq.asq_last_status);
+ 						    hw->aq.asq_last_status);
  				dev_info(&pf->pdev->dev,
- 					 "set multicast promisc failed, err %d, aq_err %d\n",
- 					 aq_ret, pf->hw.aq.asq_last_status);
+ 					 "set multicast promisc failed on %s, err %s, aq_err %s\n",
+ 					 vsi_name,
+ 					 i40e_stat_str(hw, aq_ret),
+ 					 i40e_aq_str(hw,
+ 						     hw->aq.asq_last_status));
  			}
  		}
 -		aq_ret = i40e_aq_set_vsi_broadcast(&vsi->back->hw,
 -						   vsi->seid,
 -						   cur_promisc, NULL);
 -		if (aq_ret) {
 -			retval = i40e_aq_rc_to_posix(aq_ret,
 -						     pf->hw.aq.asq_last_status);
 -			dev_info(&pf->pdev->dev,
 -				 "set brdcast promisc failed, err %s, aq_err %s\n",
 -					 i40e_stat_str(hw, aq_ret),
 -					 i40e_aq_str(hw,
 -						     hw->aq.asq_last_status));
 -		}
  	}
  out:
  	/* if something went wrong then set the changed flag so we try again */
