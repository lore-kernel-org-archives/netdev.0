From: David Miller <davem@davemloft.net>
Subject: Re: question about drivers/net/cpmac.c
Date: Sun, 13 Dec 2009 02:39:51 -0800 (PST)
Message-ID: <20091213.023951.240636069.davem@davemloft.net>
References: <Pine.LNX.4.64.0912131119540.24267@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43659
	"HELO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752371AbZLMKjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 05:39:52 -0500
In-Reply-To: <Pine.LNX.4.64.0912131119540.24267@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Sun, 13 Dec 2009 11:22:54 +0100 (CET)

> The function __devinit cpmac_probe in the file drivers/net/cpmac.c 
> contains the following code:
> 
> memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
> 
> Is it correct that the size of the pointer is what is wanted?

Everything that does sizeof(netdev->dev_addr) is a bug.

At some point we changed netdev->dev_addr from an array of chars to a
pointer to a dynamically allocated buffer.

So these cases worked before that change and need to be updated
in order to be correct.

Looking quickly there are a couple of these things under
drivers/net

