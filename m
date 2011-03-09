From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Tue, 08 Mar 2011 22:45:51 -0800 (PST)
Message-ID: <20110308.224551.226764517.davem@davemloft.net>
References: <20110309134234.32cd09b7.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, emil.s.tantilov@intel.com,
	stephen.s.ko@intel.com, jeffrey.t.kirsher@intel.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110309134234.32cd09b7.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 9 Mar 2011 13:42:34 +1100

> Hi all,
> 
> After merging the net tree, today's linux-next build (x86_64 allmodconfig)
> failed like this:
> 
> drivers/net/ixgbe/ixgbe_mbx.c: In function 'ixgbe_init_mbx_params_pf':
> drivers/net/ixgbe/ixgbe_mbx.c:456: error: 'struct ixgbe_mbx_info' has no member named 'udelay'
> 
> Caused by commit d7c8a29fc8bd20ba45ec2f52577ed04a988a9500 ("ixgbe:
> improve logic in ixgbe_init_mbx_params_pf").
> 
> I am wondering if that was ever built ...
> 
> I have used the net tree from next-20110308 for today.

Probably two minutes after you pulled this a fix went in:

commit 5217e8794619ac0a29151f29be20c7d6188303ba
Author: Andy Gospodarek <andy@greyhouse.net>
Date:   Tue Mar 8 14:26:00 2011 -0800

    ixgbe: fix compile failure in ixgbe_init_mbx_params_pf
    
    This commit:
    
        commit d7c8a29fc8bd20ba45ec2f52577ed04a988a9500
        Author: Emil Tantilov <emil.s.tantilov@intel.com>
        Date:   Thu Mar 3 09:25:02 2011 +0000
    
            ixgbe: improve logic in ixgbe_init_mbx_params_pf
    
    incorrectly added a line that accessed mbx->udelay.  I'm sure the intent
    was mbx->usec_delay.  This patch fixes the compilation error.
    
    Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/ixgbe/ixgbe_mbx.c b/drivers/net/ixgbe/ixgbe_mbx.c
index 3cf8aec..c7ed82e 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.c
+++ b/drivers/net/ixgbe/ixgbe_mbx.c
@@ -453,7 +453,7 @@ void ixgbe_init_mbx_params_pf(struct ixgbe_hw *hw)
 		return;
 
 	mbx->timeout = 0;
-	mbx->udelay = 0;
+	mbx->usec_delay = 0;
 
 	mbx->stats.msgs_tx = 0;
 	mbx->stats.msgs_rx = 0;
