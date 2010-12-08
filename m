From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: biosdevname v0.3.2
Date: Tue, 7 Dec 2010 23:19:14 -0600
Message-ID: <20101208051914.GA3203@auslistsprd01.us.dell.com>
References: <20101206140649.GA13628@auslistsprd01.us.dell.com> <1291745782.21627.6.camel@bwh-desktop> <20101207181910.GA2643@auslistsprd01.us.dell.com> <1291747282.21627.9.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	"K, Narendra" <Narendra_K@Dell.com>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>,
	Colin Watson <cjwatson@ubuntu.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1291747282.21627.9.camel@bwh-desktop>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 07, 2010 at 06:41:22PM +0000, Ben Hutchings wrote:
> On Tue, 2010-12-07 at 12:19 -0600, Matt Domsch wrote:
> > On Tue, Dec 07, 2010 at 06:16:22PM +0000, Ben Hutchings wrote:
> > > It appears that 'unknown slot' is treated as a specific slot and all
> > > devices with an unknown slot are given unique indices.  Perhaps this
> > > doesn't matter in the end, since no name is generated when the slot is
> > > unknown.
> > 
> > Yes on all counts.
> >  
> > > However, the 2 NIC ports do have their own indices (specified with the
> > > dev_id attribute) and it should be possible to distinguish slots by
> > > PCI/PCIe topology even though the name given won't correspond to any
> > > markings on the motherboard.
> > 
> > Tell me more about the dev_id attribute.  I'm happy to use it, but I
> > don't understand the rules around populating it.
> 
> As I understand it, dev_id is supposed to distinguish net devices
> corresponding to multiple ports on a single network controller.
> However, a value of 0 could mean either 'unspecified' or 'first port' so
> you would have to verify that multiple net devices for the same slot
> have unique dev_id values before taking them into account.

Only a handful of drivers seem to populate dev_id that I can find:

[drivers/net]$ grep -r -- '->dev_id' *
cxgb4/t4_hw.c:		 adap->port[i]->dev_id = j;
mlx4/en_netdev.c:	 dev->dev_id =  port - 1;
sfc/siena.c:		 efx->net_dev->dev_id = EFX_OWORD_FIELD(reg, FRF_CZ_CS_PORT_NUM) - 1;

My test system has none of these, so dev_id does have the expected
value of 0 for all ports, same card or whatever, but in all of these
drivers appear to use 0 to mean first port too.

So, I'm not sure how useful this field is in practice today.  Right
idea though...

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
