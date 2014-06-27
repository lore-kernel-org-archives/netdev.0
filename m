From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next v2 5/5] ptp: Allow reassigning calibration pin function
Date: Fri, 27 Jun 2014 12:05:33 +0200
Message-ID: <1403863533-27675-6-git-send-email-stefan.sorensen@spectralink.com>
References: <1403863533-27675-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: davem@davemloft.net, richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:31657 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753247AbaF0KGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 06:06:09 -0400
In-Reply-To: <1403863533-27675-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ptp pin function programming does not allow calibration pin to chan=
ge
function. This is problematic on hardware that uses the default calibra=
tion
pin for other purposes.

Removing this limitation does not impact calibration if userspace does =
not
reprogram the calibration pin.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/ptp/ptp_chardev.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
index 419056d..f8a7609 100644
--- a/drivers/ptp/ptp_chardev.c
+++ b/drivers/ptp/ptp_chardev.c
@@ -86,17 +86,12 @@ int ptp_set_pinfunc(struct ptp_clock *ptp, unsigned=
 int pin,
 			return -EINVAL;
 		break;
 	case PTP_PF_PHYSYNC:
-		pr_err("sorry, cannot reassign the calibration pin\n");
-		return -EINVAL;
+		if (chan !=3D 0)
+			return -EINVAL;
 	default:
 		return -EINVAL;
 	}
=20
-	if (pin2->func =3D=3D PTP_PF_PHYSYNC) {
-		pr_err("sorry, cannot reprogram the calibration pin\n");
-		return -EINVAL;
-	}
-
 	if (info->verify(info, pin, func, chan)) {
 		pr_err("driver cannot use function %u on pin %u\n", func, chan);
 		return -EOPNOTSUPP;
--=20
1.9.3
