From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: question about drivers/net/cpmac.c
Date: Sun, 13 Dec 2009 11:51:59 +0000
Message-ID: <1260705119.4532.609.camel@localhost>
References: <Pine.LNX.4.64.0912131119540.24267@ask.diku.dk>
	 <20091213.023951.240636069.davem@davemloft.net>
	 <Pine.LNX.4.64.0912131143571.24267@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, florian@openwrt.org,
	netdev@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42936 "HELO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752682AbZLMLwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 06:52:07 -0500
In-Reply-To: <Pine.LNX.4.64.0912131143571.24267@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-12-13 at 12:00 +0100, Julia Lawall wrote:
> On Sun, 13 Dec 2009, David Miller wrote:
> 
> > From: Julia Lawall <julia@diku.dk>
> > Date: Sun, 13 Dec 2009 11:22:54 +0100 (CET)
> > 
> > > The function __devinit cpmac_probe in the file drivers/net/cpmac.c 
> > > contains the following code:
> > > 
> > > memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
> > > 
> > > Is it correct that the size of the pointer is what is wanted?
> > 
> > Everything that does sizeof(netdev->dev_addr) is a bug.
> > 
> > At some point we changed netdev->dev_addr from an array of chars to a
> > pointer to a dynamically allocated buffer.
> > 
> > So these cases worked before that change and need to be updated
> > in order to be correct.
> > 
> > Looking quickly there are a couple of these things under
> > drivers/net
> 
> Fixed how?  I looked a bit to find where the field was initialized, but it 
> is just initialized to a field of something else, so it was not so 
> clear what the size should be.
[...]

The size should be dev->addr_len (assuming that has already been
initialised) which will be ETH_ALEN for Ethernet devices.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

