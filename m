From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next 2/3] dp83640: Program pulsewidth2 values of perout triggers 0 and 1
Date: Wed, 25 Jun 2014 14:37:30 +0200
Message-ID: <1403699851-11178-3-git-send-email-stefan.sorensen@spectralink.com>
References: <1403699851-11178-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: davem@davemloft.net, richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164185.static.sonofon.dk ([213.83.164.185]:59229 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752688AbaFYMhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 08:37:42 -0400
In-Reply-To: <1403699851-11178-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Periodic output triggers 0 and 1 of the dp83640 has a programmable
duty-cycle which is controlled by the Pulsewidth2 field of the trigger
data register.  This field is not documented in the datasheet, but it
is described in the "PHYTER Software Development Guide" section
3.1.4.1. Failing to set the field can result in unstable/no trigger
output.

Add programming of the Pulsewidth2 field, setting it to the same value
as the Pulsewidth field for a 50% duty cycle.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 73fada9..0343b6c 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -353,6 +353,11 @@ static int periodic_output(struct dp83640_clock *c=
lock,
 	ext_write(0, phydev, PAGE4, PTP_TDR, sec >> 16);       /* sec[31:16] =
*/
 	ext_write(0, phydev, PAGE4, PTP_TDR, pwidth & 0xffff); /* ns[15:0] */
 	ext_write(0, phydev, PAGE4, PTP_TDR, pwidth >> 16);    /* ns[31:16] *=
/
+	/* Triggers 0 and 1 has programmable pulsewidth2 */
+	if(trigger < 2) {
+		ext_write(0, phydev, PAGE4, PTP_TDR, pwidth & 0xffff);
+		ext_write(0, phydev, PAGE4, PTP_TDR, pwidth >> 16);
+	}
=20
 	/*enable trigger*/
 	val &=3D ~TRIG_LOAD;
--=20
1.9.3
