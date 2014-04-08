From: Hin-Tak Leung <htl10@users.sourceforge.net>
Subject: Re: [PATCH] rtl8187: fix use after free on failure path in rtl8187_probe()
Date: Tue, 8 Apr 2014 01:12:44 +0100 (BST)
Message-ID: <1396915964.55973.YahooMailBasic@web172301.mail.ir2.yahoo.com>
Reply-To: htl10@users.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org
To: larry.finger@lwfinger.net, khoroshilov@ispras.ru,
	herton@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm22-vm2.bullet.mail.ir2.yahoo.com ([212.82.97.8]:36637 "EHLO
	nm22-vm2.bullet.mail.ir2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753162AbaDHASd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2014 20:18:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------------------------------
On Sun, Mar 30, 2014 10:31 PM BST Larry Finger wrote:

>On 03/28/2014 03:26 PM, Alexey Khoroshilov wrote:
> If allocation of io_dmabuf fails, rtl8187_probe() calls usb_put_dev(u=
dev)
> while usb_get_dev(udev) is not called yet. As a result refcnt is decr=
emented
> incorrectly and usb_dev can be used after memory deallocation.
>
> Found by Linux Driver Verification project (linuxtesting.org).
>
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> ---
>
>Acked-by: Larry Finger <Larry.Finger@lwfinger.net>
>
>Thanks,
>
>Larry

Acked-by: Hin-Tak Leung <htl10@users.sourceforge.net>

Hin-Tak

>
>=A0=A0=A0drivers/net/wireless/rtl818x/rtl8187/dev.c | 4 ++--
>=A0=A0=A01 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/net=
/wireless/rtl818x/rtl8187/dev.c
> index fd78df813a85..d7f540a9dc9b 100644
> --- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
> +++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
> @@ -1636,10 +1636,10 @@ static int rtl8187_probe(struct usb_interface=
 *intf,
>
>=A0 =A0 err_free_dmabuf:
>=A0=A0=A0=A0=A0=A0 kfree(priv->io_dmabuf);
> - err_free_dev:
> -=A0=A0=A0 ieee80211_free_hw(dev);
>=A0=A0=A0=A0=A0=A0 usb_set_intfdata(intf, NULL);
>=A0=A0=A0=A0=A0=A0 usb_put_dev(udev);
> + err_free_dev:
> +=A0=A0=A0 ieee80211_free_hw(dev);
>=A0=A0=A0=A0=A0=A0 return err;
>=A0=A0=A0}
>
>
>
