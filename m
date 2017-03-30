From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] r8152: The Microsoft Surface docks also use R8152.
Date: Thu, 30 Mar 2017 12:06:05 -0500
Message-ID: <1490893565.24247.9.camel@redhat.com>
References: <20160113.145146.20282510666434086.davem@davemloft.net>
         <04D87F8E-0A8C-4DEC-AE66-35D9B6B0E7B7@exactcode.com>
         <20160113.154941.1886033351271894428.davem@davemloft.net>
         <20170328.064215.1055636797214516339.rene@exactcode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: Rene Rebe <rene@exactcode.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38150 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750766AbdC3RGI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 13:06:08 -0400
In-Reply-To: <20170328.064215.1055636797214516339.rene@exactcode.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-03-28 at 06:42 +0200, Rene Rebe wrote:
> Without this the generic cdc_ether grabs the device,
> and does not really work.

Does this need a corresponding blacklist in cdc_ether then?  Otherwise
you're really depending on driver loading order.

Dan

> Signed-off-by: René Rebe <rene@exactcode.com>
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index c34df33..07f788c 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -517,6 +517,7 @@ enum rtl8152_flags {
>  
>  /* Define these values to match your device */
>  #define VENDOR_ID_REALTEK              0x0bda
> +#define VENDOR_ID_MICROSOFT            0x045e
>  #define VENDOR_ID_SAMSUNG              0x04e8
>  #define VENDOR_ID_LENOVO               0x17ef
>  #define VENDOR_ID_NVIDIA               0x0955
> @@ -4521,6 +4522,8 @@ static void rtl8152_disconnect(struct
> usb_interface *intf)
>  static struct usb_device_id rtl8152_table[] = {
>         {REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
>         {REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
> +       {REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07ab)},
> +       {REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07c6)},
>         {REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
>         {REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x304f)},
>         {REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x3062)},
> 
> 
> -- 
>   René Rebe, ExactCODE GmbH, Lietzenburger Str. 42, DE-10789 Berlin
>   http://exactcode.com | http://t2-project.org | http://rene.rebe.de
