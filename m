From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Tue, 3 May 2011 13:15:48 +1000
Message-ID: <20110503131548.63dd3568.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/tg3.c between commit 6fdbab9d93e0 ("tg3: Fix failure to
enable WoL by default when possible") from the net-current tree and
commit 63c3a66fe6c8 ("tg3: Convert u32 flag,flg2,flg3 uses to bitmap")
from the net tree.

Context changes.  I fixed it up (see below) and can carry the fix as
necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/tg3.c
index 7a5daef,7c7c9a8..0000000
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@@ -12325,12 -12745,10 +12745,12 @@@ static void __devinit tg3_get_eeprom_hw
  		}
  		val = tr32(VCPU_CFGSHDW);
  		if (val & VCPU_CFGSHDW_ASPM_DBNC)
- 			tp->tg3_flags |= TG3_FLAG_ASPM_WORKAROUND;
+ 			tg3_flag_set(tp, ASPM_WORKAROUND);
  		if ((val & VCPU_CFGSHDW_WOL_ENABLE) &&
 -		    (val & VCPU_CFGSHDW_WOL_MAGPKT))
 +		    (val & VCPU_CFGSHDW_WOL_MAGPKT)) {
- 			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
+ 			tg3_flag_set(tp, WOL_ENABLE);
 +			device_set_wakeup_enable(&tp->pdev->dev, true);
 +		}
  		goto done;
  	}
  
@@@ -12460,13 -12878,11 +12880,13 @@@
  
  		if (tp->phy_flags & TG3_PHYFLG_ANY_SERDES &&
  		    !(nic_cfg & NIC_SRAM_DATA_CFG_FIBER_WOL))
- 			tp->tg3_flags &= ~TG3_FLAG_WOL_CAP;
+ 			tg3_flag_clear(tp, WOL_CAP);
  
- 		if ((tp->tg3_flags & TG3_FLAG_WOL_CAP) &&
+ 		if (tg3_flag(tp, WOL_CAP) &&
 -		    (nic_cfg & NIC_SRAM_DATA_CFG_WOL_ENABLE))
 +		    (nic_cfg & NIC_SRAM_DATA_CFG_WOL_ENABLE)) {
- 			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
+ 			tg3_flag_set(tp, WOL_ENABLE);
 +			device_set_wakeup_enable(&tp->pdev->dev, true);
 +		}
  
  		if (cfg2 & (1 << 17))
  			tp->phy_flags |= TG3_PHYFLG_CAPACITIVE_COUPLING;
