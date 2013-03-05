From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 7/7] usbnet: qmi_wwan: don't recover device if suspend fails in system sleep
Date: Tue,  5 Mar 2013 12:01:43 +0800
Message-ID: <1362456103-24956-8-git-send-email-ming.lei@canonical.com>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org,
	Ming Lei <ming.lei@canonical.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If suspend callback fails in system sleep context, usb core will
ignore the failure and let system sleep go ahead further, so
this patch doesn't recover device under this situation.

Cc: Bj=C3=B8rn Mork <bjorn@mork.no>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/qmi_wwan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index efb5c7c..fce18be 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -294,7 +294,7 @@ static int qmi_wwan_suspend(struct usb_interface *i=
ntf, pm_message_t message)
=20
 	if (intf =3D=3D info->control && info->subdriver && info->subdriver->=
suspend)
 		ret =3D info->subdriver->suspend(intf, message);
-	if (ret < 0)
+	if (ret < 0  && PMSG_IS_AUTO(msg))
 		usbnet_resume(intf);
 err:
 	return ret;
--=20
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-input" =
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
