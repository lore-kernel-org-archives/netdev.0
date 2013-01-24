From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [RFC] net: usbnet: prevent buggy devices from killing us
Date: Thu, 24 Jan 2013 16:39:18 +0400
Message-ID: <51012B76.1060600@mvista.com>
References: <1359023152-32576-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:39353 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065Ab3AXMjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 07:39:37 -0500
Received: by mail-la0-f52.google.com with SMTP id fs12so2993447lab.25
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 04:39:35 -0800 (PST)
In-Reply-To: <1359023152-32576-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 24-01-2013 14:25, Bj=C3=B8rn Mork wrote:

> A device sending 0 length frames as fast as it can has been
> observed killing the host system due to the resulting memory
> pressure. We handle the done queue as fast as we can, so
> if this queue is filling up then that is an indication that we
> are under too heavy pressure.  Refusing further allocations
> until the done queue is handled prevents the buggy device
> from taking the system down.
>
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
[...]

>   drivers/net/usb/usbnet.c |    8 ++++++++
>   1 files changed, 8 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index f34b2eb..85c7ffd 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -380,6 +380,14 @@ static int rx_submit (struct usbnet *dev, struct=
 urb *urb, gfp_t flags)
>   	unsigned long		lockflags;
>   	size_t			size =3D dev->rx_urb_size;
>
> +	/* Do not let a device flood us to death! */
> +	if (dev->done.qlen > 1024) {
> +		netif_dbg(dev, rx_err, dev->net, "done queue filling up (%u) - thr=
ottling\n", dev->done.qlen);
> +		usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
> +		usb_free_urb (urb);

    Run your patch thru scripts/checkpatch.pl please -- spaces before p=
arens=20
are not allowed.

WBR, Sergei
