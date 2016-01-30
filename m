From: Andrea Merello <andrea.merello-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] rtl818x_pci: Disable pci device in error handling code
Date: Sat, 30 Jan 2016 17:19:12 +0100
Message-ID: <CAN8YU5O+DAzUZWtw5Rp8PTcA-O=H-JxwYrKghE_OFr+L4MA3RQ@mail.gmail.com>
References: <1452949379-16052-1-git-send-email-baijiaju1990@163.com>
Reply-To: andrea.merello-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1452949379-16052-1-git-send-email-baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Acked-by: Andrea Merello <andrea.merello-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

On Sat, Jan 16, 2016 at 2:02 PM, Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org> wrote:
> When pci_request_regions in rtl8180_probe fails, pci_disable_device is not
> called to disable the device which is enabled by pci_enbale_device.
>
> This patch fixes the problem by adding a new lable in error handling code.
>
> Signed-off-by: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
> ---
>  drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c b/drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c
> index a43a16f..c76af5d 100644
> --- a/drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c
> +++ b/drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c
> @@ -1736,7 +1736,7 @@ static int rtl8180_probe(struct pci_dev *pdev,
>         if (err) {
>                 printk(KERN_ERR "%s (rtl8180): Cannot obtain PCI resources\n",
>                        pci_name(pdev));
> -               return err;
> +               goto err_disable_dev;
>         }
>
>         io_addr = pci_resource_start(pdev, 0);
> @@ -1938,6 +1938,8 @@ static int rtl8180_probe(struct pci_dev *pdev,
>
>   err_free_reg:
>         pci_release_regions(pdev);
> +
> + err_disable_dev:
>         pci_disable_device(pdev);
>         return err;
>  }
> --
> 1.7.9.5
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
