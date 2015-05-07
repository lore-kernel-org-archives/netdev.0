From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: usb: allow MTU that is a multiple of USB packet
 size
Date: Thu, 07 May 2015 16:24:27 +0300
Message-ID: <554B678B.7090103@cogentembedded.com>
References: <1430992159-27783-1-git-send-email-ruslan.bilovol@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ruslan Bilovol <ruslan.bilovol@gmail.com>, oneukum@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430992159-27783-1-git-send-email-ruslan.bilovol@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 5/7/2015 12:49 PM, Ruslan Bilovol wrote:

> Current usbnet driver rejects setting MTU that is a multiple
> of USB endpoint's wMaxPacketSize size. However, it may only
> lead to possible performance degradation but is not so
> critical that its using should be prohibited. So allow it
> but also warn user about possible issue.

> Signed-off-by: Ruslan Bilovol <ruslan.bilovol@gmail.com>
> ---
>   drivers/net/usb/usbnet.c |    6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 733f4fe..09dc848 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -382,9 +382,11 @@ int usbnet_change_mtu (struct net_device *net, int new_mtu)
>
>   	if (new_mtu <= 0)
>   		return -EINVAL;
> -	// no second zero-length packet read wanted after mtu-sized packets
> +	/* warn about second zero-length packet read after mtu-sized packets */
>   	if ((ll_mtu % dev->maxpacket) == 0)
> -		return -EDOM;
> +		netdev_warn(dev->net, "MTU %d is a multiple of USB wMaxPacketSize (%d),"
> +				" consider possible performance degradation\n",

    Please do not wrap the kernel messages, it impedes grepping for them. 
scripts/checkpatch.pl is aware of this rule.

WBR, Sergei
