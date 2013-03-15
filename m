From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v3 4/7] usbnet: cdc_mbim: comments on suspend failure
Date: Fri, 15 Mar 2013 12:08:56 +0800
Message-ID: <1363320539-23012-5-git-send-email-ming.lei@canonical.com>
References: <1363320539-23012-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org,
	Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:57956 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243Ab3COEJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 00:09:58 -0400
In-Reply-To: <1363320539-23012-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If suspend callback fails in system sleep context, usb core will
ignore the failure and let system sleep go ahead further, so
this patch comments on the case and requires that both
usbnet_suspend() and subdriver->suspend() MUST return 0 in
system sleep context.

Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/cdc_mbim.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 248d2dc..406a34d 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -332,6 +332,11 @@ static int cdc_mbim_suspend(struct usb_interface *=
intf, pm_message_t message)
 		goto error;
 	}
=20
+	/*
+	 * Both usbnet_suspend() and subdriver->suspend() MUST return 0
+	 * in system sleep context, otherwise, the resume callback has
+	 * to recover device from previous suspend failure.
+	 */
 	ret =3D usbnet_suspend(intf, message);
 	if (ret < 0)
 		goto error;
--=20
1.7.9.5
