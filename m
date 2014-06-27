From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next v2 1/5] dp83640: Program pulsewidth2 values of perout triggers 0 and 1
Date: Fri, 27 Jun 2014 12:05:29 +0200
Message-ID: <1403863533-27675-2-git-send-email-stefan.sorensen@spectralink.com>
References: <1403863533-27675-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: davem@davemloft.net, richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:52645 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753171AbaF0KGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 06:06:03 -0400
In-Reply-To: <1403863533-27675-1-git-send-email-stefan.sorensen@spectralink.com>
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
index 6a999e6..fcd50b77 100644
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
+	if (trigger < 2) {
+		ext_write(0, phydev, PAGE4, PTP_TDR, pwidth & 0xffff);
+		ext_write(0, phydev, PAGE4, PTP_TDR, pwidth >> 16);
+	}
=20
 	/*enable trigger*/
 	val &=3D ~TRIG_LOAD;
--=20
1.9.3
