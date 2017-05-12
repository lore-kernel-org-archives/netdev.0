From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: dsa: mv88e6xxx: add default case to switch
Date: Thu, 11 May 2017 22:11:29 -0500
Message-ID: <20170512031129.GA4065@embeddedgus>
References: <20170511214814.Horde.otwLVFIaWFNJZ23PSdgsq_Z@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway34.websitewelcome.com ([192.185.150.114]:22187 "EHLO
        gateway34.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754841AbdELDLe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 23:11:34 -0400
Received: from cm6.websitewelcome.com (cm6.websitewelcome.com [108.167.139.19])
        by gateway34.websitewelcome.com (Postfix) with ESMTP id 1AEAB164C0
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 22:11:32 -0500 (CDT)
Content-Disposition: inline
In-Reply-To: <20170511214814.Horde.otwLVFIaWFNJZ23PSdgsq_Z@gator4166.hostgator.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add default case to switch in order to avoid any chance of using an
uninitialized variable _low_, in case s->type does not match any of
the listed case values.

Addresses-Coverity-ID: 1398130
Suggested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 03dc886..d39e210 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -879,6 +879,9 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_chip *chip,
 		mv88e6xxx_g1_stats_read(chip, reg, &low);
 		if (s->sizeof_stat == 8)
 			mv88e6xxx_g1_stats_read(chip, reg + 1, &high);
+		break;
+	default:
+		return UINT64_MAX;
 	}
 	value = (((u64)high) << 16) | low;
 	return value;
-- 
2.5.0
