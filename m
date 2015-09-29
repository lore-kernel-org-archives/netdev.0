From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] [net] orinoco_usb:Fix error handling in ezusb_probe()
Date: Tue, 29 Sep 2015 11:33:26 +0300
Message-ID: <87mvw57hgp.fsf@kamboji.qca.qualcomm.com>
References: <52c0b90f.10cf0.14ff4df0cc4.Coremail.zy900702@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: RUC_Soft_Sec <zy900702-9Onoh4P/yGk@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52c0b90f.10cf0.14ff4df0cc4.Coremail.zy900702-9Onoh4P/yGk@public.gmane.org> (RUC Soft
	Sec's message of "Tue, 22 Sep 2015 19:45:02 +0800 (CST)")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

RUC_Soft_Sec <zy900702-9Onoh4P/yGk@public.gmane.org> writes:

> Current code assigns 0 to variable 'retval', which makes ezusb_probe() to
> return success even if alloc_orinocodev() fails.
>
> The related code snippets in mantis_dma_init() is as following.
>
> 1573 static int ezusb_probe(struct usb_interface *interface,
> 1574                        const struct usb_device_id *id)
> 1575 {
>
>                  ....
>
> 1583         int retval = 0;
> 1584         int i;
> 1585
> 1586         priv = alloc_orinocodev(sizeof(*upriv), &udev->dev,
> 1587                                 ezusb_hard_reset, NULL);
> 1588         if (!priv) {
> 1589                 err("Couldn't allocate orinocodev");
> 1590                 goto exit;
> 1591         }
>                  ...
>
> 1729  exit:
> 1730         if (fw_entry) {
> 1731                 firmware.code = NULL;
> 1732                 firmware.size = 0;
> 1733                 release_firmware(fw_entry);
> 1734         }
> 1735         usb_set_intfdata(interface, upriv);
> 1736         return retval;
> 1737 }
>
>  Fix it by checking the return value from alloc_orinocodev() and assigns
> '-ENOMEM' to variable 'retval' in the case of error.
>
> Signed-off-by: Zhang Yan <zy900702-9Onoh4P/yGk@public.gmane.org>---
>  orinoco_usb.c |    1 +
>  1 file changed, 1 insertion(+)
> diff --git a/orinoco_usb.c b/orinoco_usb.c

The patch looks corrupted. And the from header doesn't contain a proper
name.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
