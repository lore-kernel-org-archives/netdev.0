From: Andrew Goodbody <andrew.goodbody@cambrionix.com>
Subject: [PATCH v2 0/1] drivers: net: cpsw: Fix NULL pointer dereference with two slave PHYs
Date: Mon, 18 Apr 2016 14:53:25 +0100
Message-ID: <1460987606-18125-1-git-send-email-andrew.goodbody@cambrionix.com>
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

v1 had a problem that data->slaves was used before it had been filled in

Andrew Goodbody (1):
  Prevent NUll pointer dereference with two PHYs on cpsw

 drivers/net/ethernet/ti/cpsw.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

-- 
2.5.0
