From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] isdn: make sure strings are null terminated
Date: Wed, 23 Nov 2011 09:42:05 +0300
Message-ID: <20111123064204.GA6871@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:59032 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758373Ab1KWGmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 01:42:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These strings come from the user.  We strcpy() them inside
cf_command() so we should check that they are NULL terminated and
return an error if not.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/divert/divert_procfs.c b/drivers/isdn/divert/divert_procfs.c
index 33ec9e4..0c16687 100644
--- a/drivers/isdn/divert/divert_procfs.c
+++ b/drivers/isdn/divert/divert_procfs.c
@@ -242,6 +242,10 @@ static int isdn_divert_ioctl_unlocked(struct file *file, uint cmd, ulong arg)
 		case IIOCDOCFINT:
 			if (!divert_if.drv_to_name(dioctl.cf_ctrl.drvid))
 				return (-EINVAL);	/* invalid driver */
+			if (strlen(dioctl.cf_ctrl.msn) >= sizeof(dioctl.cf_ctrl.msn))
+				return -EINVAL;
+			if (strlen(dioctl.cf_ctrl.fwd_nr) >= sizeof(dioctl.cf_ctrl.fwd_nr))
+				return -EINVAL;
 			if ((i = cf_command(dioctl.cf_ctrl.drvid,
 					    (cmd == IIOCDOCFACT) ? 1 : (cmd == IIOCDOCFDIS) ? 0 : 2,
 					    dioctl.cf_ctrl.cfproc,
