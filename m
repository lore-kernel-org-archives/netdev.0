From: Doug Anderson <dianders@chromium.org>
Subject: Re: [PATCH V3] r8152: add Linksys USB3GIGV1 id
Date: Wed, 27 Sep 2017 16:47:09 -0700
Message-ID: <CAD=FV=U-zMEQ8=_96SMENmcBywG0hSrDvebXUxGGbAur_2T-4g@mail.gmail.com>
References: <20170927172802.80654-1-grundler@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Hayes Wang <hayeswang@realtek.com>,
        Oliver Neukum <oneukum@suse.com>,
        linux-usb <linux-usb@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Grant Grundler <grundler@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170927172802.80654-1-grundler@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Sep 27, 2017 at 10:28 AM, Grant Grundler <grundler@chromium.org> wrote:
> This linksys dongle by default comes up in cdc_ether mode.
> This patch allows r8152 to claim the device:
>    Bus 002 Device 002: ID 13b1:0041 Linksys
>
> Signed-off-by: Grant Grundler <grundler@chromium.org>
> ---
>  drivers/net/usb/cdc_ether.c | 10 ++++++++++
>  drivers/net/usb/r8152.c     |  2 ++
>  2 files changed, 12 insertions(+)
>
> V3: for backwards compat, add #ifdef CONFIG_USB_RTL8152 around
>     the cdc_ether blacklist entry so the cdc_ether driver can
>     still claim the device if r8152 driver isn't configured.
>
> V2: add LINKSYS_VENDOR_ID to cdc_ether blacklist
>
> diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
> index 8ab281b478f2..446dcc0f1f70 100644
> --- a/drivers/net/usb/cdc_ether.c
> +++ b/drivers/net/usb/cdc_ether.c
> @@ -546,6 +546,7 @@ static const struct driver_info wwan_info = {
>  #define DELL_VENDOR_ID         0x413C
>  #define REALTEK_VENDOR_ID      0x0bda
>  #define SAMSUNG_VENDOR_ID      0x04e8
> +#define LINKSYS_VENDOR_ID      0x13b1
>  #define LENOVO_VENDOR_ID       0x17ef

Slight nit that "LI" sorts after "LE".  You got it right in the other case...


>  #define NVIDIA_VENDOR_ID       0x0955
>  #define HP_VENDOR_ID           0x03f0
> @@ -737,6 +738,15 @@ static const struct usb_device_id  products[] = {
>         .driver_info = 0,
>  },
>
> +#ifdef CONFIG_USB_RTL8152
> +/* Linksys USB3GIGV1 Ethernet Adapter */
> +{
> +       USB_DEVICE_AND_INTERFACE_INFO(LINKSYS_VENDOR_ID, 0x0041, USB_CLASS_COMM,
> +                       USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
> +       .driver_info = 0,
> +},
> +#endif

I believe you want to use IS_ENABLED(), don't you?

There's still a weird esoteric side case where kernel modules don't
all need to be included in the filesystem just because they were built
at the same time.  ...but IMHO that seems like enough of a nit that we
can probably ignore it unless someone has a better idea.


-Doug
