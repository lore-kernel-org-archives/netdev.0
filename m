From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] rt2800usb:fix efuse detection
Date: Sun, 01 Jun 2014 23:06:11 +0400
Message-ID: <538B79A3.1080104@cogentembedded.com>
References: <20140601174736.7980.18330.stgit@charlie.fem.tu-ilmenau.de> <20140601175247.7980.2461.stgit@charlie.fem.tu-ilmenau.de>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140601175247.7980.2461.stgit@charlie.fem.tu-ilmenau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/01/2014 09:52 PM, Michael Braun wrote:

> The device 057c:8501 (AVM Fritz! WLAN v2 rev. B) currently does not
> load. One thing observed is that the vendors driver detects EFUSE mode
> for this device, but rt2800usb does not. This is due to rt2800usb
> lacking a check for the firmware mode present in the vendors driver,
> that this patch adopts for rt2800usb.

> With this patch applied, the 'RF chipset' detection does no longer fail.

> Signed-off-by: Michael Braun <michael-dev@fami-braun.de>
> ---
>   drivers/net/wireless/rt2x00/rt2800usb.c |   16 +++++++++++++++-
>   1 file changed, 15 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
> index a49c3d7..b601422 100644
> --- a/drivers/net/wireless/rt2x00/rt2800usb.c
> +++ b/drivers/net/wireless/rt2x00/rt2800usb.c
> @@ -735,11 +735,25 @@ static void rt2800usb_fill_rxdone(struct queue_entry *entry,
>   /*
>    * Device probe functions.
>    */
> +static int rt2800usb_efuse_detect(struct rt2x00_dev *rt2x00dev)
> +{
> +	__le32 fwMode;
> +
> +	rt2x00usb_vendor_request(rt2x00dev, USB_DEVICE_MODE,
> +				 USB_VENDOR_REQUEST_IN, 0, 0x11, &fwMode,
> +				 sizeof(fwMode), REGISTER_TIMEOUT_FIRMWARE);
> +
> +	if ((fwMode & 0x00000003) == 2)

    Operating directly on '__le32'? That doesn't look right.

> +		return 1;
> +
> +	return rt2800_efuse_detect(rt2x00dev);
> +}
> +

WBR, Sergei
