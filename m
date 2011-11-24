From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2] isdn: make sure strings are null terminated
Date: Thu, 24 Nov 2011 15:41:49 +0300
Message-ID: <20111124124149.GH3195@mwanda>
References: <20111123064204.GA6871@elgon.mountain>
 <1322031811.1298.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YrlhzR9YrZtruaFS"
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:53835 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab1KXMll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 07:41:41 -0500
Content-Disposition: inline
In-Reply-To: <1322031811.1298.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YrlhzR9YrZtruaFS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

These strings come from the user.  We strcpy() them inside
cf_command() so we should check that they are NULL terminated and
return an error if not.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: use strnlen() instead of strlen().

diff --git a/drivers/isdn/divert/divert_procfs.c b/drivers/isdn/divert/divert_procfs.c
index 33ec9e4..9021182 100644
--- a/drivers/isdn/divert/divert_procfs.c
+++ b/drivers/isdn/divert/divert_procfs.c
@@ -242,6 +242,12 @@ static int isdn_divert_ioctl_unlocked(struct file *file, uint cmd, ulong arg)
 		case IIOCDOCFINT:
 			if (!divert_if.drv_to_name(dioctl.cf_ctrl.drvid))
 				return (-EINVAL);	/* invalid driver */
+			if (strnlen(dioctl.cf_ctrl.msn, sizeof(dioctl.cf_ctrl.msn)) ==
+					sizeof(dioctl.cf_ctrl.msn))
+				return -EINVAL;
+			if (strnlen(dioctl.cf_ctrl.fwd_nr, sizeof(dioctl.cf_ctrl.fwd_nr)) ==
+					sizeof(dioctl.cf_ctrl.fwd_nr))
+				return -EINVAL;
 			if ((i = cf_command(dioctl.cf_ctrl.drvid,
 					    (cmd == IIOCDOCFACT) ? 1 : (cmd == IIOCDOCFDIS) ? 0 : 2,
 					    dioctl.cf_ctrl.cfproc,

--YrlhzR9YrZtruaFS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJOzjuNAAoJEOnZkXI/YHqRFV0P/0Ewj3jHxmf+e8sRKFh5pF75
zQob7D9LSwKvzhmXMirmKOS8ocFOd4Gy0l3oPRir6LNJQjkqH+VGxc4L9eVrRUNw
voJV7Y9+yXU2Y1vnZtgu46ViHydZSgD2fMdLOgPDshiLNqoxdFkLQDTZsduAwdhc
4bPcZ1E1g0FuNZI6M5v6ypFJvg/DQPiJ+4gOrSfodO8eb6kPICzbB00aS4c5CSFr
orvtGcsF78TfV7QcDuqjNaH31AlAXJx3ByxTNocgVn6JaC4V9AVGRaxRgc8knE3I
bD1pYV/TlBW7Az+dFoblhGgtVQqb+dcDvNsz0nGMP2Ykaps+ths1U5ydKIlMap18
TXtFZKa5M8ETxGQ2xffGqT359++aNrkT6OBhm1KGuHazQGVSWB3c59Yih6qQyoJq
lomCv85cecFj7JGW1Wt9W2dE07NLD8LHrX+Y0tfFJNgsn9Hn2cn/eS1XIL9xwFR9
XDDoMojXgBJew+AnhE0PkmBxvlVG19K53Yf0ztmq+DMSN7u0Kutymm2o5KuK+NoS
zu2r5hbX39I7VMiZF/NNRtVdn08AVOc0n7uMXLPfJGBf/Y6s3Vfdmx/RxWke+qDl
WsApyEoe/Uh3CSTKPm3a5Lnvc8uFyWrO6A1N8itcCdqbgumKmC5aliaWjg63yG4u
UkV42M0sbj1ZCdgyOkoc
=2h7E
-----END PGP SIGNATURE-----

--YrlhzR9YrZtruaFS--
