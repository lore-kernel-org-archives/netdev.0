From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: Re: [PATCH 00/11] usbnet: usbnet: handle link change
Date: Thu, 11 Apr 2013 18:18:09 +0300
Message-ID: <5166D431.4080400@iki.fi>
References: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-mail-sa-02.sanoma.fi ([158.127.18.162]:56013 "EHLO
	sd-mail-sa-02.sanoma.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379Ab3DKPSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 11:18:13 -0400
In-Reply-To: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11.04.2013 17:40, Ming Lei wrote:
> Hi,
> 
> This patch set introduces usbnet_link_change() API and applies
> it on all usbnet drivers, then handle the link change centrally
> to stop bulk transfer when link becomes off and restart bulk
> transfer when link becomes on.

Should 'rndis_wlan' be changed to use this too?

-Jussi

> 
> With the change, ~10% performance boost on bulk transfer
> of another device on the same bus can be obtained when link
> is off. Also, stopping bulk transfer when link becomes off
> may disable asynchonous schedule of host controller, power
> might be saved probabally.
> 
>  drivers/net/usb/asix_devices.c |    6 +-----
>  drivers/net/usb/ax88179_178a.c |   12 ++++-------
>  drivers/net/usb/cdc_ether.c    |    5 +----
>  drivers/net/usb/cdc_ncm.c      |    9 +++-----
>  drivers/net/usb/dm9601.c       |    7 +------
>  drivers/net/usb/mcs7830.c      |    6 +-----
>  drivers/net/usb/sierra_net.c   |    3 +--
>  drivers/net/usb/usbnet.c       |   45 +++++++++++++++++++++++++++++++++++++++-
>  include/linux/usb/usbnet.h     |    2 ++
>  9 files changed, 58 insertions(+), 37 deletions(-)
> 
> 
> Thanks,
> --
> Ming Lei
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
