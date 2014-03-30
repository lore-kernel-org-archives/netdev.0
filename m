From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtl8187: fix use after free on failure path in rtl8187_probe()
Date: Sun, 30 Mar 2014 16:31:33 -0500
Message-ID: <53388D35.8080902@lwfinger.net>
References: <1396038375-18122-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Herton Ronaldo Krzesinski <herton@canonical.com>,
	Hin-Tak Leung <htl10@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396038375-18122-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/28/2014 03:26 PM, Alexey Khoroshilov wrote:
> If allocation of io_dmabuf fails, rtl8187_probe() calls usb_put_dev(udev)
> while usb_get_dev(udev) is not called yet. As a result refcnt is decremented
> incorrectly and usb_dev can be used after memory deallocation.
>
> Found by Linux Driver Verification project (linuxtesting.org).
>
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> ---

Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Thanks,

Larry

>   drivers/net/wireless/rtl818x/rtl8187/dev.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/net/wireless/rtl818x/rtl8187/dev.c
> index fd78df813a85..d7f540a9dc9b 100644
> --- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
> +++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
> @@ -1636,10 +1636,10 @@ static int rtl8187_probe(struct usb_interface *intf,
>
>    err_free_dmabuf:
>   	kfree(priv->io_dmabuf);
> - err_free_dev:
> -	ieee80211_free_hw(dev);
>   	usb_set_intfdata(intf, NULL);
>   	usb_put_dev(udev);
> + err_free_dev:
> +	ieee80211_free_hw(dev);
>   	return err;
>   }
>
>
