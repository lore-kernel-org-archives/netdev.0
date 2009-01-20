From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] usb/mcs7830: Don't use buffers from stack for USB transfers
Date: Tue, 20 Jan 2009 23:45:47 +0100
Message-ID: <200901202345.47792.arnd@arndb.de>
References: <34115.192.168.0.40.1232483361.squirrel@server>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Christian Eggers" <ceggers@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:54356 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755551AbZATWpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 17:45:55 -0500
In-Reply-To: <34115.192.168.0.40.1232483361.squirrel@server>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 20 January 2009, you wrote:
> From: Christian Eggers <christian.eggers@kathrein.de>
> 
> mcs7830_set_reg() and mcs7830_get_reg() are called with buffers
> from stack which must not be used directly for USB transfers.
> This causes corruption of the stack particulary on non x86
> architectures because DMA may be used for these transfers.
> 
> Signed-off-by: Christian Eggers <christian.eggers@kathrein.de>

Have you observed problems with this, or just suspected trouble?

When I wrote this code, I looked at other code doing the same
and assumed it was ok, because usb_control_msg waits for the
DMA to complete before returning.

Is the problem only on systems that have noncoherent DMA, or
something else?

> This is my first patch submission for Linux. I hope everything is fine.

I was about to say that you should have Cc:'d me, but then I noticed
that I'm not listed in the driver as maintainer, nor in the MAINTAINERS
file, so I can't really complain here ;-)

	Arnd <><
