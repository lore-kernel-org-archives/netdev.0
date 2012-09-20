From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] USB: remove dbg() usage in USB networking drivers
Date: Thu, 20 Sep 2012 03:07:13 -0700
Message-ID: <1348135633.5604.5.camel@joe2Laptop>
References: <20120919171316.GA12248@kroah.com>
	 <1348077212.22122.13.camel@joe2Laptop> <20120919193536.GA13933@kroah.com>
	 <20120919194614.GA17585@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37444 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752985Ab2ITKHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2012 06:07:16 -0400
In-Reply-To: <20120919194614.GA17585@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 20:46 +0100, Greg Kroah-Hartman wrote:
> The dbg() USB macro is so old, it predates me.  The USB networking drivers are
> the last hold-out using this macro, and we want to get rid of it, so replace
> the usage of it with the proper netdev_dbg() or dev_dbg() (depending on the
> context) calls.

OK, one more bit of trivia

> diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
[]
> @@ -422,8 +419,9 @@ static int net1080_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
>  	if (!(skb->len & 0x01)) {
>  #ifdef DEBUG
>  		struct net_device	*net = dev->net;
> -		dbg("rx framesize %d range %d..%d mtu %d", skb->len,
> -			net->hard_header_len, dev->hard_mtu, net->mtu);
> +		netdev_dbg(dev->net, "rx framesize %d range %d..%d mtu %d\n",
> +			   skb->len, net->hard_header_len, dev->hard_mtu,
> +			   net->mtu);
>  #endif

maybe
		netdev_dbg(net, ...

or remove the odd #ifdef DEBUG surround used to guard
the otherwise unused net variable and use:

		netdev_dbg(dev->net, "rx framesize %d range %d..%d mtu %d\n",
			   skb->len, dev->net->hard_header_len, dev->hard_mtu,
			   dev->net->mtu);
