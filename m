From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.1 11/56] mvneta: add forgotten initialization of autonegotiation bits
Date: Wed,  8 Jul 2015 00:35:00 -0700
Message-ID: <20150708073238.389781888@linuxfoundation.org>
References: <20150708073237.780280770@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org, Arnaud Ebalard <arno@natisbad.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, Stas Sergeev <stsp@users.sourceforge.net>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150708073237.780280770@linuxfoundation.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

4.1-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Stas Sergeev <stsp@list.ru>

[ Upstream commit 538761b794c1542f1c6e31eadd9d7aae118889f7 ]

The commit 898b2970e2c9 ("mvneta: implement SGMII-based in-band link state
signaling")
changed mvneta_adjust_link() so that it does not clear the auto-negotiation
bits in MVNETA_GMAC_AUTONEG_CONFIG register. This was necessary for
auto-negotiation mode to work.
Unfortunately I haven't checked if these bits are ever initialized.
It appears they are not.
This patch adds the missing initialization of the auto-negotiation bits
in the MVNETA_GMAC_AUTONEG_CONFIG register.
It fixes the following regression:
https://www.mail-archive.com/netdev@vger.kernel.org/msg67928.html

Since the patch was tested to fix a regression, it should be applied to
stable tree.

Tested-by: Arnaud Ebalard <arno@natisbad.org>

CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
CC: Florian Fainelli <f.fainelli@gmail.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
CC: stable@vger.kernel.org

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/ethernet/marvell/mvneta.c |    6 ++++++
 1 file changed, 6 insertions(+)

--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1013,6 +1013,12 @@ static void mvneta_defaults_set(struct m
 		val = mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
 		val |= MVNETA_GMAC_1MS_CLOCK_ENABLE;
 		mvreg_write(pp, MVNETA_GMAC_CLOCK_DIVIDER, val);
+	} else {
+		val = mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
+		val &= ~(MVNETA_GMAC_INBAND_AN_ENABLE |
+		       MVNETA_GMAC_AN_SPEED_EN |
+		       MVNETA_GMAC_AN_DUPLEX_EN);
+		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
 	}
 
 	mvneta_set_ucast_table(pp, -1);
