From: Julia Lawall <julia@diku.dk>
Subject: Re: question about drivers/net/cpmac.c
Date: Sun, 13 Dec 2009 12:00:11 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0912131143571.24267@ask.diku.dk>
References: <Pine.LNX.4.64.0912131119540.24267@ask.diku.dk>
 <20091213.023951.240636069.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: florian@openwrt.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:35985 "HELO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750898AbZLMLAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 06:00:14 -0500
In-Reply-To: <20091213.023951.240636069.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Dec 2009, David Miller wrote:

> From: Julia Lawall <julia@diku.dk>
> Date: Sun, 13 Dec 2009 11:22:54 +0100 (CET)
> 
> > The function __devinit cpmac_probe in the file drivers/net/cpmac.c 
> > contains the following code:
> > 
> > memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
> > 
> > Is it correct that the size of the pointer is what is wanted?
> 
> Everything that does sizeof(netdev->dev_addr) is a bug.
> 
> At some point we changed netdev->dev_addr from an array of chars to a
> pointer to a dynamically allocated buffer.
> 
> So these cases worked before that change and need to be updated
> in order to be correct.
> 
> Looking quickly there are a couple of these things under
> drivers/net

Fixed how?  I looked a bit to find where the field was initialized, but it 
is just initialized to a field of something else, so it was not so 
clear what the size should be.

I found the following elsewhere:

memcmp(eth->h_dest, dev->dev_addr, dev->addr_len)

Could these cases be changed to use the addr_len field? On the other hand, 
only rtl8150.c contains any mention of the addr_len field.

        memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
	dbg("%s: Setting MAC address to ", netdev->name);
        for (i = 0; i < 5; i++)
                dbg("%02X:", netdev->dev_addr[i]);
        dbg("%02X\n", netdev->dev_addr[i]);
        /* Set the IDR registers. */
        set_registers(dev, IDR, sizeof(netdev->dev_addr), netdev->dev_addr);


julia
