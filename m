From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 10/15] m68k: Some network drivers do not check the
	platform
Date: Thu, 24 Apr 2008 14:42:56 -0400
Message-ID: <20080424184256.GA8531@infradead.org>
References: <20080424182940.424312704@mail.of.borg> <20080424183242.943446357@mail.of.borg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:36512 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320AbYDXSm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 14:42:59 -0400
Content-Disposition: inline
In-Reply-To: <20080424183242.943446357@mail.of.borg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 08:29:50PM +0200, Geert Uytterhoeven wrote:
> +++ b/drivers/net/macmace.c
> @@ -781,6 +781,9 @@ static int __init mac_mace_init_module(v
>  {
>  	int err;
>  
> +	if (!MACH_IS_MAC)
> +		return -ENODEV;
> +
>  	if ((err = platform_driver_register(&mac_mace_driver))) {
>  		printk(KERN_ERR "Driver registration failed\n");
>  		return err;

This is rather odd.  The whole point of the platform_driver
infrastructure is that the arch code only registers it if it's present
and then the driver can match for it.  So the right fix here is to move
the platform_driver_register(&mac_mace_driver) into the mac arch setup
code.  A quick grep shows this is a quite common pattern for m68k
drivers.

