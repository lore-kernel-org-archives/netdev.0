From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 1/3] fixed_phy: handle link-down case
Date: Tue, 14 Jul 2015 20:11:00 +0300
Message-ID: <55A542A4.80700@list.ru>
References: <55A5424D.4030809@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55A5424D.4030809@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Currently fixed_phy driver recognizes only the link-up state.
This simple patch adds an implementation of link-down state.
It fixes the status registers when link is down, and also allows
to register the fixed-phy with link down without specifying the speed.

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>

CC: Florian Fainelli <f.fainelli@gmail.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
---
 drivers/net/phy/fixed_phy.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index 1960b46..479b93f 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -52,6 +52,10 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
 	u16 lpagb = 0;
 	u16 lpa = 0;

+	if (!fp->status.link)
+		goto done;
+	bmsr |= BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
+
 	if (fp->status.duplex) {
 		bmcr |= BMCR_FULLDPLX;

@@ -96,15 +100,13 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
 		}
 	}

-	if (fp->status.link)
-		bmsr |= BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
-
 	if (fp->status.pause)
 		lpa |= LPA_PAUSE_CAP;

 	if (fp->status.asym_pause)
 		lpa |= LPA_PAUSE_ASYM;

+done:
 	fp->regs[MII_PHYSID1] = 0;
 	fp->regs[MII_PHYSID2] = 0;

-- 
1.9.1
