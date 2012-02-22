From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] hso: memsetting wrong data in hso_get_count()
Date: Wed, 22 Feb 2012 10:30:25 +0300
Message-ID: <20120222073024.GA7389@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: Jan Dumon <j.dumon@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:50034 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058Ab2BVHaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 02:30:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The intent was to clear out the icount struct here, but we accidentally
clear stack memory instead.  It probably will lead to a NULL dereference
right away.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 304fe78..e1324b4 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1632,7 +1632,7 @@ static int hso_get_count(struct tty_struct *tty,
 	struct hso_serial *serial = get_serial_by_tty(tty);
 	struct hso_tiocmget  *tiocmget = serial->tiocmget;
 
-	memset(&icount, 0, sizeof(struct serial_icounter_struct));
+	memset(icount, 0, sizeof(struct serial_icounter_struct));
 
 	if (!tiocmget)
 		 return -ENOENT;
