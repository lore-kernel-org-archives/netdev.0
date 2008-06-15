From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: page allocation failure
Date: Sun, 15 Jun 2008 10:04:47 +0400
Message-ID: <20080615060447.GB2643@2ka.mipt.ru>
References: <20080614022451.M72462@visp.net.lb> <20080614065845.GB32585@2ka.mipt.ru> <20080614205958.M55299@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40972 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751128AbYFOGEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jun 2008 02:04:40 -0400
Content-Disposition: inline
In-Reply-To: <20080614205958.M55299@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Sun, Jun 15, 2008 at 12:02:16AM +0300, Denys Fedoryshchenko (denys@visp.net.lb) wrote:
> There is no jumbo frames in this particular setup.
> Probably it is getting out of memory (rtorrent using almost all for fs caching
> maybe).

Than it is very strange, why would it want to do order-3 allocation,
since its allocation size is calculated as follows:
rx_size = bp->dev->mtu + ETH_HLEN + bp->rx_offset + 8;
bp->rx_buf_use_size = rx_size;
/* hw alignment */
bp->rx_buf_size = bp->rx_buf_use_size + BNX2_RX_ALIGN

where rx_offset is 18 bytes and BNX2_RX_ALIGN is 16 bytes.
Network stack adds small structure at the end too, but it should not
jump out of 0-order allocation.

-- 
	Evgeniy Polyakov
