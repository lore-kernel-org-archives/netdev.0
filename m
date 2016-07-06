From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 6 Jul 2016 11:32:28 +1000
Message-ID: <20160706113228.114c942c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	hayeswang <hayeswang@realtek.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/usb/r8152.c

between commit:

  2609af19362d ("r8152: fix runtime function for RTL8152")

from the net tree and commit:

  a028a9e003f2 ("r8152: move the settings of PHY to a work queue")

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

diff --cc drivers/net/usb/r8152.c
index 0da72d39b4f9,24d367280ecf..000000000000
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@@ -624,7 -624,7 +624,8 @@@ struct r8152 
  		int (*eee_get)(struct r8152 *, struct ethtool_eee *);
  		int (*eee_set)(struct r8152 *, struct ethtool_eee *);
  		bool (*in_nway)(struct r8152 *);
 +		void (*autosuspend_en)(struct r8152 *tp, bool enable);
+ 		void (*hw_phy_cfg)(struct r8152 *);
  	} rtl_ops;
  
  	int intr_interval;
@@@ -4156,7 -4157,7 +4176,8 @@@ static int rtl_ops_init(struct r8152 *t
  		ops->eee_get		= r8152_get_eee;
  		ops->eee_set		= r8152_set_eee;
  		ops->in_nway		= rtl8152_in_nway;
 +		ops->autosuspend_en	= rtl_runtime_suspend_enable;
+ 		ops->hw_phy_cfg		= r8152b_hw_phy_cfg;
  		break;
  
  	case RTL_VER_03:
@@@ -4172,7 -4173,7 +4193,8 @@@
  		ops->eee_get		= r8153_get_eee;
  		ops->eee_set		= r8153_set_eee;
  		ops->in_nway		= rtl8153_in_nway;
 +		ops->autosuspend_en	= rtl8153_runtime_enable;
+ 		ops->hw_phy_cfg		= r8153_hw_phy_cfg;
  		break;
  
  	default:
