From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [ANNOUNCEMENT] NET: usb: sierra_net.c driver
Date: Sun, 28 Mar 2010 08:57:01 -0700
Message-ID: <1269791821.11714.202.camel@localhost.localdomain>
References: <1269652919.30630.1.camel@Linuxdev3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Brownell <dbrownell@users.sourceforge.net>,
	Rory Filer <rfiler@sierrawireless.com>, netdev@vger.kernel.org,
	linux-usb <linux-usb@vger.kernel.org>
To: Elina Pasheva <epasheva@sierrawireless.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:39327 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab0C1P5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 11:57:09 -0400
In-Reply-To: <1269652919.30630.1.camel@Linuxdev3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Elina,

> +static const struct driver_info sierra_net_info_68A3 = {
> +	.description = "Sierra Wireless USB-Ethernet Modem",
> +	.flags = FLAG_ETHER | FLAG_SEND_ZLP,
> +	.bind = sierra_net_bind,
> +	.unbind = sierra_net_unbind,
> +	.status = sierra_net_status,
> +	.rx_fixup = sierra_net_rx_fixup,
> +	.tx_fixup = sierra_net_tx_fixup,
> +	.data = (unsigned long)&sierra_net_info_data_68A3,
> +};

the FLAG_ETHER is wrong here. Please use FLAG_WWAN to clearly mark these
interfaces.

Otherwise we have wrong DEVTYPE uevent assignments and userspace will
treat them as real Ethernet cards. And that should not happen. As a nice
benefit the interface name will be wwan%d by default as well.

Regards

Marcel


