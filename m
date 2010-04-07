From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Wed, 7 Apr 2010 12:58:45 +1000
Message-ID: <20100407125845.c5308d84.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/via-velocity.c between commit
bcbe53682f65330bdd9ad7eed9575d2ff536353a ("via-velocity: Fix
FLOW_CNTL_TX_RX handling in set_mii_flow_control()") from Linus' tree and
commit 3a7f8681ffb27bcc540fb74cda15e39c9395737b ("via-velocity: remove
private #define") from the net tree.

I fixed it up (see below) and can carry the fix for a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/via-velocity.c
index bc278d4,078903f..0000000
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@@ -811,8 -811,8 +811,8 @@@ static void set_mii_flow_control(struc
  		break;
  
  	case FLOW_CNTL_TX_RX:
- 		MII_REG_BITS_ON(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
- 		MII_REG_BITS_OFF(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
+ 		MII_REG_BITS_ON(ADVERTISE_PAUSE_CAP, MII_ADVERTISE, vptr->mac_regs);
 -		MII_REG_BITS_ON(ADVERTISE_PAUSE_ASYM, MII_ADVERTISE, vptr->mac_regs);
++		MII_REG_BITS_OFF(ADVERTISE_PAUSE_ASYM, MII_ADVERTISE, vptr->mac_regs);
  		break;
  
  	case FLOW_CNTL_DISABLE:
