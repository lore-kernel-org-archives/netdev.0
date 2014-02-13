From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH v3 1/3] net:phy:dp83640: Program pulsewidth2 values of perout triggers 0 and 1
Date: Thu, 13 Feb 2014 15:35:23 +0100
Message-ID: <1392302129-24947-2-git-send-email-stefan.sorensen@spectralink.com>
References: <1392302129-24947-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: richardcochran@gmail.com, grant.likely@linaro.org,
	robh+dt@kernel.org, mark.rutland@arm.com,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392302129-24947-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Periodic output triggers 0 and 1 of the dp83640 has a programmable
duty-cycle which is controlled by the Pulsewidth2 field of the trigger
data register.  This field is not documented in the datasheet, but it
is described in the "PHYTER Software Development Guide" section
3.1.4.1. Failing to set the field can result in unstable/no trigger
output.

This patch add programming of the Pulsewidth2 field, setting it to the
same value as the Pulsewidth field for a 50% duty cycle.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 5ff221d..a370814 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -312,6 +312,11 @@ static void periodic_output(struct dp83640_clock *=
clock,
 	ext_write(0, phydev, PAGE4, PTP_TDR, sec >> 16);       /* sec[31:16] =
*/
 	ext_write(0, phydev, PAGE4, PTP_TDR, period & 0xffff); /* ns[15:0] */
 	ext_write(0, phydev, PAGE4, PTP_TDR, period >> 16);    /* ns[31:16] *=
/
+	/* Triggers 0 and 1 has programmable pulsewidth2 */
+	if (trigger =3D=3D 0 || trigger =3D=3D 1) {
+		ext_write(0, phydev, PAGE4, PTP_TDR, period & 0xffff);
+		ext_write(0, phydev, PAGE4, PTP_TDR, period >> 16);
+	}
=20
 	/*enable trigger*/
 	val &=3D ~TRIG_LOAD;
--=20
1.8.5.3
