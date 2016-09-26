From: Chris Roth <chris.roth@usask.ca>
Subject: Re: [PATCH v2] Net Driver: Add Cypress GX3 VID=04b4 PID=3610.
Date: Mon, 26 Sep 2016 15:56:59 -0600
Message-ID: <CAPZMiRa6=So14ic8SMSkbHdrVH8-7vA1+Wg_hWJoAgr8G_mhyw@mail.gmail.com>
References: <271e26e7350f418bad08761cab439005@Mail06.usask.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <271e26e7350f418bad08761cab439005@Mail06.usask.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm not sure what I'm doing wrong:

I'm trying to get the from statement to read original author (Allan
Chou) first, and then me (Chris Roth) second. I've used the following
two commands:

git format-patch -o /tmp/ --subject-prefix="PATCH v2" --from="Allan
Chou <allan@asix.com.tw>" HEAD^

and

git send-email --to linux-usb@vger.kernel.org --to
netdev@vger.kernel.org --to linux-kernel@vger.kernel.org --from="Allan
Chou <allan@asix.com.tw>"
/tmp/0001-Net-Driver-Add-Cypress-GX3-VID-04b4-PID-3610.patch

I thought that adding the --from portions to the git format-patch and
git send-email commands would force the addition of Allan to the top
of the patch, but it hasn't. Can anyone tell me specifically how I
need to change these commands in order to get the desired result? Then
I'll submit a PATCH v3.

Regards,
Chris

On Mon, Sep 26, 2016 at 3:48 PM, Allan Chou <allan@asix.com.tw> wrote:
> From: Chris Roth <chris.roth@usask.ca>
>
> Add support for Cypress GX3 SuperSpeed to Gigabit Ethernet
> Bridge Controller (Vendor=04b4 ProdID=3610).
>
> Patch verified on x64 linux kernel 4.7.4 system with the
> Kensington SD4600P USB-C Universal Dock with Power, which uses the
> Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge Controller.
>
> A similar patch was signed-off and tested-by Allan Chou
> <allan@asix.com.tw> on 2015-12-01.
>
> Allan verified his similar patch on x86 Linux kernel 4.1.6 system
> with Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge Controller.
>
> Tested-by: Allan Chou <allan@asix.com.tw>
> Tested-by: Chris Roth <chris.roth@usask.ca>
>
> Signed-off-by: Allan Chou <allan@asix.com.tw>
> Signed-off-by: Chris Roth <chris.roth@usask.ca>
> ---
>  drivers/net/usb/ax88179_178a.c | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
>
> diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
> index e6338c1..8a6675d 100644
> --- a/drivers/net/usb/ax88179_178a.c
> +++ b/drivers/net/usb/ax88179_178a.c
> @@ -1656,6 +1656,19 @@ static const struct driver_info ax88178a_info = {
>         .tx_fixup = ax88179_tx_fixup,
>  };
>
> +static const struct driver_info cypress_GX3_info = {
> +       .description = "Cypress GX3 SuperSpeed to Gigabit Ethernet Controller",
> +       .bind = ax88179_bind,
> +       .unbind = ax88179_unbind,
> +       .status = ax88179_status,
> +       .link_reset = ax88179_link_reset,
> +       .reset = ax88179_reset,
> +       .stop = ax88179_stop,
> +       .flags = FLAG_ETHER | FLAG_FRAMING_AX,
> +       .rx_fixup = ax88179_rx_fixup,
> +       .tx_fixup = ax88179_tx_fixup,
> +};
> +
>  static const struct driver_info dlink_dub1312_info = {
>         .description = "D-Link DUB-1312 USB 3.0 to Gigabit Ethernet Adapter",
>         .bind = ax88179_bind,
> @@ -1718,6 +1731,10 @@ static const struct usb_device_id products[] = {
>         USB_DEVICE(0x0b95, 0x178a),
>         .driver_info = (unsigned long)&ax88178a_info,
>  }, {
> +       /* Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge Controller */
> +       USB_DEVICE(0x04b4, 0x3610),
> +       .driver_info = (unsigned long)&cypress_GX3_info,
> +}, {
>         /* D-Link DUB-1312 USB 3.0 to Gigabit Ethernet Adapter */
>         USB_DEVICE(0x2001, 0x4a00),
>         .driver_info = (unsigned long)&dlink_dub1312_info,
> --
> 2.7.4
>
