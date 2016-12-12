From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tip tree with the net-next tree
Date: Mon, 12 Dec 2016 13:30:00 +1100
Message-ID: <20161212133000.6cf7a90e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        WingMan Kwok <w-kwok2@ti.com>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the tip tree got a conflict in:

  drivers/net/ethernet/ti/Kconfig

between commit:

  6246168b4a38 ("net: ethernet: ti: netcp: add support of cpts")

from the net-next tree and commit:

  d1cbfd771ce8 ("ptp_clock: Allow for it to be optional")

from the tip tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/ti/Kconfig
index dc217fd7a734,61b835a7e6ae..000000000000
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@@ -74,14 -74,13 +74,14 @@@ config TI_CPS
  	  will be called cpsw.
  
  config TI_CPTS
 -	bool "TI Common Platform Time Sync (CPTS) Support"
 -	depends on TI_CPSW
 +	tristate "TI Common Platform Time Sync (CPTS) Support"
 +	depends on TI_CPSW || TI_KEYSTONE_NETCP
- 	select PTP_1588_CLOCK
+ 	imply PTP_1588_CLOCK
  	---help---
  	  This driver supports the Common Platform Time Sync unit of
 -	  the CPSW Ethernet Switch. The unit can time stamp PTP UDP/IPv4
 -	  and Layer 2 packets, and the driver offers a PTP Hardware Clock.
 +	  the CPSW Ethernet Switch and Keystone 2 1g/10g Switch Subsystem.
 +	  The unit can time stamp PTP UDP/IPv4 and Layer 2 packets, and the
 +	  driver offers a PTP Hardware Clock.
  
  config TI_KEYSTONE_NETCP
  	tristate "TI Keystone NETCP Core Support"
