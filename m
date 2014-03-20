From: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Subject: [PATCH 0/5] sh_eth: Fix the race between open and MDIO bus registration
Date: Thu, 20 Mar 2014 15:00:30 +0100
Message-ID: <1395324035-22918-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Cc: linux-sh@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This patch series fixes the race condition that exists in the sh_eth driver
between network device open and MDIO bus registration. The actual fix is in
patch 4/5, with previous patches preparing the driver and patch 5/5 cleaning
up an unrelated issue.

I've based the idea on Sergei's attempt to fix the problem and can successfully
boot the Koelsch board over NFS with this series. I might have missed other
issues though, hence the RFC status.

The patches are based on top of the latest net-next master branch.

Laurent Pinchart (5):
  sh_eth: Use the platform device for memory allocation
  sh_eth: Use the platform device as the MDIO bus parent
  sh_eth: Simplify MDIO bus initialization and release
  sh_eth: Register MDIO bus before registering the network device
  sh_eth: Remove goto statements that jump straight to a return

 drivers/net/ethernet/renesas/sh_eth.c | 85 +++++++++++++----------------------
 1 file changed, 31 insertions(+), 54 deletions(-)

-- 
Regards,

Laurent Pinchart

