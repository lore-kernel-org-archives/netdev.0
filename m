From: Krishna Chaitanya <chaitanya.mgit@gmail.com>
Subject: Re: [PATCH] p54usb: fix leaks at failure path in p54u_probe()
Date: Sun, 9 Mar 2014 04:14:32 +0530
Message-ID: <CABPxzYLzMvtWShP_PFdyTzV8P1P177yPZh=xAO=3tiy97UfEmQ@mail.gmail.com>
References: <1394226709-10763-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Cc: Christian Lamparter <chunkeey@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:60680 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbaCHWoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 17:44:54 -0500
In-Reply-To: <1394226709-10763-1-git-send-email-khoroshilov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 8, 2014 at 2:41 AM, Alexey Khoroshilov
<khoroshilov@ispras.ru> wrote:
> If p54u_load_firmware() fails, p54u_probe() does not deallocate
> already allocated resources. The patch adds proper failure handling.
>
> Found by Linux Driver Verification project (linuxtesting.org).
>
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> ---
>  drivers/net/wireless/p54/p54usb.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
> index 6e635cfa24c8..5df74503fd4f 100644
> --- a/drivers/net/wireless/p54/p54usb.c
> +++ b/drivers/net/wireless/p54/p54usb.c
> @@ -1053,6 +1053,10 @@ static int p54u_probe(struct usb_interface *intf,
>                 priv->upload_fw = p54u_upload_firmware_net2280;
>         }
>         err = p54u_load_firmware(dev, intf);
> +       if (err) {
> +               usb_put_dev(udev);
> +               p54_free_common(dev);
> +       }
>         return err;
>  }
The load_firmware puts down the reference
in case of error. Only free is required here.
