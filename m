From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] net/usb/kalmia: use %*phC to dump small buffers
Date: Tue, 28 May 2013 22:14:01 +0400
Message-ID: <51A4F3E9.4090108@cogentembedded.com>
References: <1369734966-29026-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1369734966-29026-1-git-send-email-andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 28-05-2013 13:56, Andy Shevchenko wrote:

> Instead of dereferencing pointer and put values on stack we could use nice
> %*phC specifier.

> Signed-off-by: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> ---
>   drivers/net/usb/kalmia.c | 46 ++++++++++++++++------------------------------
>   1 file changed, 16 insertions(+), 30 deletions(-)

> diff --git a/drivers/net/usb/kalmia.c b/drivers/net/usb/kalmia.c
> index 0192073..13ecfc5 100644
> --- a/drivers/net/usb/kalmia.c
> +++ b/drivers/net/usb/kalmia.c
[...]
> @@ -263,32 +260,24 @@ kalmia_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
>   				sizeof(EXPECTED_UNKNOWN_HEADER_1)) || !memcmp(
>   				header_start, EXPECTED_UNKNOWN_HEADER_2,
>   				sizeof(EXPECTED_UNKNOWN_HEADER_2))) {
> -				netdev_dbg(
> -					dev->net,
> -					"Received expected unknown frame header: %02x:%02x:%02x:%02x:%02x:%02x. Package length: %i\n",
> -					header_start[0], header_start[1],
> -					header_start[2], header_start[3],
> -					header_start[4], header_start[5],
> +				netdev_dbg(dev->net,
> +					"Received expected unknown frame "
> +					"header: %6phC. Package length: %i\n",

    Message strings shouldn't be broken, despite 80 chars limit (there's an
exception for them in checkpatch.pl).

> +					header_start,
>   					skb->len - KALMIA_HEADER_LENGTH);
>   			}
>   			else {
> -				netdev_err(
> -					dev->net,
> -					"Received unknown frame header: %02x:%02x:%02x:%02x:%02x:%02x. Package length: %i\n",
> -					header_start[0], header_start[1],
> -					header_start[2], header_start[3],
> -					header_start[4], header_start[5],
> +				netdev_err(dev->net,
> +					"Received unknown frame header: %6phC. "
> +					"Package length: %i\n", header_start,

    Same here...

>   					skb->len - KALMIA_HEADER_LENGTH);
>   				return 0;
>   			}
>   		}
[...]
> @@ -310,12 +299,9 @@ kalmia_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
>   				sizeof(HEADER_END_OF_USB_PACKET)) == 0);
>   			if (!is_last) {
>   				header_start = skb->data + ether_packet_length;
> -				netdev_dbg(
> -					dev->net,
> -					"End header: %02x:%02x:%02x:%02x:%02x:%02x. Package length: %i\n",
> -					header_start[0], header_start[1],
> -					header_start[2], header_start[3],
> -					header_start[4], header_start[5],
> +				netdev_dbg(dev->net,
> +					"End header: %6phC. Package length: %i"
> +					"\n", header_start,

    ... and here.

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
