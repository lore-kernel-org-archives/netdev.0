From: Stefano Brivio <sbrivio-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] rtl8xxxu: Don't printk raw binary if serial number is
 not burned in.
Date: Fri, 8 Sep 2017 03:27:06 +0200
Message-ID: <20170908032706.1fa59da9@elisabeth>
References: <20170907235103.5359-1-kilobyte@angband.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <Jes.Sorensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Adam Borowski <kilobyte-b9QjgO8OEXPVItvQsEIGlw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170907235103.5359-1-kilobyte-b9QjgO8OEXPVItvQsEIGlw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri,  8 Sep 2017 01:51:03 +0200
Adam Borowski <kilobyte-b9QjgO8OEXPVItvQsEIGlw@public.gmane.org> wrote:

> I assume that a blank efuse comes with all ones, thus I did not bother
> recognizing other possible junk values.  This matches 100% of dongles
> I've seen (a single Gembird 8192eu).
> 
> Signed-off-by: Adam Borowski <kilobyte-b9QjgO8OEXPVItvQsEIGlw@public.gmane.org>
> ---
>  drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
> index 80fee699f58a..bdc37e7272ca 100644
> --- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
> +++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
> @@ -614,7 +614,11 @@ static int rtl8192eu_parse_efuse(struct rtl8xxxu_priv *priv)
>  
>  	dev_info(&priv->udev->dev, "Vendor: %.7s\n", efuse->vendor_name);
>  	dev_info(&priv->udev->dev, "Product: %.11s\n", efuse->device_name);
> -	dev_info(&priv->udev->dev, "Serial: %.11s\n", efuse->serial);
> +	if (strncmp(efuse->serial,
> +		    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff", 11))

You might want to use memchr_inv():

	if (memchr_inv(efuse->serial, 0xff, 11))
		dev_info(&priv->udev->dev, "Serial: %.11s\n", efuse->serial);
	...

Mostly cosmetic though.

--
Stefano
