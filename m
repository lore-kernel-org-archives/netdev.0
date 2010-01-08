From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] drivers/net/defxx.c: use %pMF to show MAC address
Date: Fri, 8 Jan 2010 02:06:14 +0000 (GMT)
Message-ID: <alpine.LFD.2.00.1001080143250.13474@eddie.linux-mips.org>
References: <201001071624.20139.hartleys@visionengravers.com> <1262914750.10429.88.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: H Hartley Sweeten <hartleys@visionengravers.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753240Ab0AHCGQ@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:43621 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S1492997Ab0AHCGO (ORCPT
        <rfc822;netdev@vger.kernel.org> + 1 other);
        Fri, 8 Jan 2010 03:06:14 +0100
In-Reply-To: <1262914750.10429.88.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Jan 2010, Joe Perches wrote:

> On Thu, 2010-01-07 at 16:24 -0700, H Hartley Sweeten wrote:
> > Use the %pMF kernel extension to display the MAC address.
> > The address will still be displayed in the FDDI Canonical format.
> 
> > diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
> > index 6a6ea03..e4eac4b 100644
> > --- a/drivers/net/defxx.c
> > +++ b/drivers/net/defxx.c
> > @@ -1052,12 +1052,9 @@ static int __devinit dfx_driver_init(struct net_device *dev,
> >  		board_name = "DEFEA";
> >  	if (dfx_bus_pci)
> >  		board_name = "DEFPA";
> > -	pr_info("%s: %s at %saddr = 0x%llx, IRQ = %d, "
> > -		"Hardware addr = %02X-%02X-%02X-%02X-%02X-%02X\n",
> > +	pr_info("%s: %s at %saddr = 0x%llx, IRQ = %d, Hardware addr = %pMF\n",
> >  		print_name, board_name, dfx_use_mmio ? "" : "I/O ",
> 
> I believe the output will _now_ be in the canonical form.
> Before it wasn't bit reversed.  Now it should be.

 Output was correct -- why would you assume otherwise?  The bit order in 
the MLA (My Long Address) register as retrieved from the MAC chip by 
board's firmware has nothing to do with the wire order and is already in 
the canonical form (the same applies to CAM entries and frame headers) -- 
the board designers were sane people.

 With the two patches in place the output produced is now broken. :(

  Maciej
