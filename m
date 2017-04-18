From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Marvell phy errata origins?
Date: Tue, 18 Apr 2017 16:04:50 +0200
Message-ID: <20170418140450.GB13724@lunn.ch>
References: <59691a35-a89c-f9ca-c7b0-73134a737f4c@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andy Fleming <afleming@freescale.com>,
        Harini Katakam <harini.katakam@xilinx.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        HEMANT RAMDASI <hramdasi@cisco.com>,
        "Julius Hemanth Pitti -X (jpitti - MONTA VISTA SOFTWARE INC at Cisco)"
        <jpitti@cisco.com>
To: Daniel Walker <danielwa@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33028 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753466AbdDROE5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 10:04:57 -0400
Content-Disposition: inline
In-Reply-To: <59691a35-a89c-f9ca-c7b0-73134a737f4c@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 06:16:33AM -0700, Daniel Walker wrote:
> 
> Hi,
> 
> Cisco is using a Marvell 88E1112 phy. It seems to be fairly similar
> to the 88E1111 which Harini added a fix for.

Hi Daniel

If you look at Marvell reference drive, DSDT, they are actually quite
different. Different virtual cable tester, different downshift
configuration, different packet generator, different loopback. I would
say they are different generations of PHY.

> In Harini's commit
> message for ,
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/drivers/net/phy/marvell.c?id=3ec0a0f10ceb
> 
> "This function has a sequence accessing Page 5 and Register 31, both
> of which are not defined or reserved for this PHY"
> 
> For the 88E1112 we see that these are "Factory Test Modes" which the
> contents of are not documented. They aren't really "not defied", and
> aren't really "reserved" .. Marvell support claims they don't
> support these drivers, and Freescale seems to be adding these
> drivers, and the line we are looking at.
> 
> We had some issues with our PHY which were corrected with the same
> patch Harini used but modified for the M88E1112. We're trying to get
> to the bottom of where this code came from and what it was suppose
> to be doing.

I tried to find this errata fix in the Marvell reference code. And
failed to find it. But it is "Vendor Crap" code, hard to find anything
in it.

My guess is, this errata just applies to one model of PHY, maybe even
one revision of one model of a PHY. The hard bit is figuring out what
actually needs it. Do you have access to Marvell datasheets?

Otherwise, go back to what appears to be the first commit for this
driver:

commit 00db8189d984d6c51226dafbbe4a667ce9b7d5da
Author: Andy Fleming <afleming@freescale.com>
Date:   Sat Jul 30 19:31:23 2005 -0400

    This patch adds a PHY Abstraction Layer to the Linux Kernel, enabling
    ethernet drivers to remain as ignorant as is reasonable of the connected
    PHY's design and operation details.
    
    Signed-off-by: Andy Fleming <afleming@freescale.com>
    Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

It seems a reasonable guess that any PHY added after this commit does
not need the errata.

    Andrew
