From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [REGRESSION, BISECTED] Broken networking with net/phy/marvell
Date: Mon, 30 Oct 2017 11:40:25 +0100
Message-ID: <20171030104025.GA12275@lunn.ch>
References: <20171026122836.zoggs44rkasflr3m@darkstar.musicnaut.iki.fi>
 <20171028190139.GA17645@lunn.ch>
 <20171030001954.rlrbldsle7v5ti5p@darkstar.musicnaut.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        netdev@vger.kernel.org
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:33472 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751917AbdJ3Kkg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 06:40:36 -0400
Content-Disposition: inline
In-Reply-To: <20171030001954.rlrbldsle7v5ti5p@darkstar.musicnaut.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 02:19:54AM +0200, Aaro Koskinen wrote:
> Hi,
> 
> On Sat, Oct 28, 2017 at 09:01:39PM +0200, Andrew Lunn wrote:
> > On Thu, Oct 26, 2017 at 03:28:36PM +0300, Aaro Koskinen wrote:
> > > When upgrading from v4.13 to v4.14-rc6 on OpenRD Client, the box loses
> > > network connectivity.
> > 
> > What exactly is the PHY in the OpenRD?
> 
> 88E1116R.
> 
> > Please can you print the value of mscr before it is changed.
> 
> [    3.377836] MSCR BEFORE: 00001070
> [    3.381176]  MSCR AFTER: 00001040
 
> > One possibility, is that the bootloader is setting the PHY to
> > rgmii-id.

So the initial value does seem to suggest the bootloader is setting
it.

 This is now getting cleared, where earlier it was
> > preserved. If this is true, it should be solved by adding
> > 
> > phy-mode = "rgmii-id" to the ethernet node in the device tree.
> 
> Ok, that seems to help:
> 
> [    3.377852] MSCR BEFORE: 00001070
> [    3.381189]  MSCR AFTER: 00001070

Great. Thanks for testing this. I don't like it regressing though, so
i want to see if it is possible to fix this without needing to add the
phy mode. I hope to look at this in the next couple of days.

    Thanks

	Andrew
 
