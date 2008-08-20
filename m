From: greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org
Subject: [patch 02/02] hso: dev_kfree_skb crash fix
Date: Tue, 19 Aug 2008 18:07:55 -0700
Message-ID: <20080820010755.GC3365@kroah.com>
References: <20080820010353.593820280@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
To: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename="hso-dev_kfree_skb-crash-fix.patch"
In-Reply-To: <20080820010738.GA3365-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>

Fixes dev_kfree_skb happening too many times when hso_start_net_device
is called from hso_resume.

Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Cc: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

---
 drivers/net/usb/hso.c |    1 +
 1 file changed, 1 insertion(+)

--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2613,6 +2613,7 @@ static int hso_resume(struct usb_interfa
 					"Transmitting lingering data\n");
 				hso_net_start_xmit(hso_net->skb_tx_buf,
 						   hso_net->net);
+				hso_net->skb_tx_buf = NULL;
 			}
 			result = hso_start_net_device(network_table[i]);
 			if (result)

-- 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
