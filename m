From: Andrew Goodbody <andrew.goodbody@cambrionix.com>
Subject: [PATCH] Fix NULL pointer dereference in cpsw with two slave PHYs
Date: Wed, 13 Apr 2016 15:36:47 +0100
Message-ID: <1460558208-1374-1-git-send-email-andrew.goodbody@cambrionix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Andrew Goodbody <andrew.goodbody@cambrionix.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a fix for a NULL pointer dereference from cpsw which is triggered
by having two slave PHYs attached to a cpsw network device. The problem is
due to only maintaining a single reference to a PHY node in the prive data
which gets overwritten by the second PHY probe. So move the PHY node
reference to the individual slave data so that there is now one per slave.

Andrew Goodbody (1):
  Prevent NUll pointer dereference with two PHYs on cpsw

 drivers/net/ethernet/ti/cpsw.c | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

-- 
2.5.0
