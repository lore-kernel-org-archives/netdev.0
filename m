From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] phylib: update mdiobus_alloc() to allocate extra private
 space
Date: Thu, 15 Dec 2011 11:12:01 -0600
Message-ID: <4EEA2A61.8050302@freescale.com>
References: <1323967895-5205-1-git-send-email-timur@freescale.com> <8ABCAC4C-1D11-41AD-AE46-96EB9D40588D@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:51515 "EHLO
	TX2EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759266Ab1LORXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 12:23:44 -0500
In-Reply-To: <8ABCAC4C-1D11-41AD-AE46-96EB9D40588D@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> Why? Doesn't this just obfuscate things a little, while providing no immediate benefit?

I see code like this frequently:

	bus = mdiobus_alloc();
	if (bus == NULL)
		return -ENOMEM;
	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
	if (priv == NULL) {
		err = -ENOMEM;
		goto out_free;
	}
	bus->priv = priv;

This can be replaced with:

	bus = mdiobus_alloc(sizeof(*priv));
	if (bus == NULL)
		return -ENOMEM;

So the benefit is in simplifying memory management.  Now you have only one allocation to manage, instead of two.

fbdev does the same thing, which is where I got the idea from.  See framebuffer_alloc().

-- 
Timur Tabi
Linux kernel developer at Freescale
