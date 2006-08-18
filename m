From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 5/6]: powerpc/cell spidernet bottom half
Date: Sat, 19 Aug 2006 01:03:04 +0200
Message-ID: <200608190103.05649.arnd@arndb.de>
References: <20060818220700.GG26889@austin.ibm.com> <20060818222657.GL26889@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>,
	Jeff Garzik <jgarzik@pobox.com>, akpm@osdl.org,
	netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org,
	ens Osterkamp <Jens.Osterkamp@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:39420 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1751572AbWHRXDS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 19:03:18 -0400
To: linuxppc-dev@ozlabs.org
In-Reply-To: <20060818222657.GL26889@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 19 August 2006 00:26, Linas Vepstas wrote:
> The recent set of low-waterark patches for the spider result in a
> significant amount of computing being done in an interrupt context.
> This patch moves this to a "bottom half" aka work queue, so that
> the code runs in a normal kernel context. Curiously, this seems to 
> result in a performance boost of about 5% for large packets.

I guess this one still needs some work. We already have a bottom
half mechanism in the network layer, using the NAPI poll function
that is strongly serialized.

Linas, you wrote that you have tried doing the TX descriptor cleanup
in dev->poll(), but I think you missed the point that this function
needs should then be scheduled whenever necessary.

This seems a little strange, but I think what we need to do is in the
low-watermark interrupt call netif_rx_schedule(netdev) in order to
arrange for the ->poll function to be called in the next softirq.

Someone should probably document that in 
Documentation/networking/NAPI_HOWTO.txt, I might end up doing that
once we get it right for spidernet.

	Arnd <><
