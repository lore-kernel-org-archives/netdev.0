From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] rt2800usb:fix hang during firmware load
Date: Sun, 01 Jun 2014 23:09:24 +0400
Message-ID: <538B7A64.1000306@cogentembedded.com>
References: <20140601174736.7980.18330.stgit@charlie.fem.tu-ilmenau.de> <20140601175252.7980.64143.stgit@charlie.fem.tu-ilmenau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, users@rt2x00.serialmonkey.com,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Michael Braun <michael-dev@fami-braun.de>,
	Ivo van Doorn <IvDoorn@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:51189 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512AbaFATJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 15:09:26 -0400
Received: by mail-lb0-f181.google.com with SMTP id q8so2063872lbi.12
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 12:09:24 -0700 (PDT)
In-Reply-To: <20140601175252.7980.64143.stgit@charlie.fem.tu-ilmenau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2014 09:52 PM, Michael Braun wrote:

> The device 057c:8501 (AVM Fritz! WLAN v2 rev. B) boots into a state that does not actually require loading a firmware file.

    Wrap the changelog lines on at least 80 chars please.

> The vendors driver finds out about this by checking a firmware state
> register, so this patch adopts this here.

> Finally, with this patch applied, my wifi dongle actually becomes
> usefull (scan + connect to wpa network works).

    s/usefull/useful/.

> Signed-off-by: Michael Braun <michael-dev@fami-braun.de>
> ---
>   drivers/net/wireless/rt2x00/rt2800usb.c |   14 ++++++++++++--
>   1 file changed, 12 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
> index b601422..71bf101 100644
> --- a/drivers/net/wireless/rt2x00/rt2800usb.c
> +++ b/drivers/net/wireless/rt2x00/rt2800usb.c
> @@ -240,6 +240,7 @@ static int rt2800usb_write_firmware(struct rt2x00_dev *rt2x00dev,
>   	int status;
>   	u32 offset;
>   	u32 length;
> +	__le32 fwMode;
>
>   	/*
>   	 * Check which section of the firmware we need.
> @@ -257,8 +258,17 @@ static int rt2800usb_write_firmware(struct rt2x00_dev *rt2x00dev,
>   	/*
>   	 * Write firmware to device.
>   	 */
> -	rt2x00usb_register_multiwrite(rt2x00dev, FIRMWARE_IMAGE_BASE,
> -				      data + offset, length);
> +	rt2x00usb_vendor_request(rt2x00dev, USB_DEVICE_MODE,
> +				 USB_VENDOR_REQUEST_IN, 0, 0x11, &fwMode,
> +				 sizeof(fwMode), REGISTER_TIMEOUT_FIRMWARE);
> +
> +	if ((fwMode & 0x00000003) == 2) {

    Same comment as for the patch #1.

> +		rt2x00_info(rt2x00dev,
> +		      "Firmware loading not required - NIC in AutoRun mode\n");

    This line should start under 'rt2xx00dev', like below.

> +	} else {
> +		rt2x00usb_register_multiwrite(rt2x00dev, FIRMWARE_IMAGE_BASE,
> +					      data + offset, length);
> +	}

WBR, Sergei
