From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx instead of MSI-X
Date: Tue, 26 Oct 2010 14:32:34 +0100
Message-ID: <20101026133233.GH15074@solarflare.com>
References: <20101025111235.GA2024@emulex.com> <20101025.120943.189699949.davem@davemloft.net> <20101025223853.GD15074@solarflare.com> <20101025.162535.226782713.davem@davemloft.net> <1288075928.6578.185.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, somnath.kotur@emulex.com,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: Michael Ellerman <michael@ellerman.id.au>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1288075928.6578.185.camel@concordia>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Ellerman wrote:
> On Mon, 2010-10-25 at 16:25 -0700, David Miller wrote:
> > From: Ben Hutchings <bhutchings@solarflare.com>
> > Date: Mon, 25 Oct 2010 23:38:53 +0100
> > 
> > > David Miller wrote:
> > >> From: Somnath Kotur <somnath.kotur@emulex.com>
> > >> Date: Mon, 25 Oct 2010 16:42:35 +0530
> > >> 
> > >> > By default, be2net uses MSIx wherever possible.
> > >> > Adding a module parameter to use INTx for users who do not want to use MSIx.
> > >> > 
> > >> > Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
> > >> 
> > >> Either add a new ethtool flag, or use the PCI subsystem facilities
> > >> for tweaking things to implement this.
> > >>
> > >> Do not use a module option, otherwise every other networking driver
> > >> author will get the same "cool" idea, give the module option
> > >> different names, and the resulting user experience is terrible.
> > > 
> > > This has already happened, sadly.  So far as I can see it's mostly done
> > > to allow users to work around systems with broken MSIs; I'm not aware of
> > > any other reason to prefer legacy interrupts.  However, the PCI subsystem
> > > already implements a blacklist and a kernel parameter for disabling MSIs
> > > on these systems.
> > 
> > The PCI subsystem bits I'm totally fine with.
> > 
> > But in the drivers themselves, that's what I don't want.
> 
> That horse has really really bolted, it's gawn.
> 
> I count 26 drivers with "disable MSI/X" parameters. Some even have more
> than one.
> 
> 11 of them are network drivers, 9 scsi, 3 ata.
> 
> I agree it's a mess for users, but it's probably preferable to a
> non-working driver.
> 
> Ethtool would be nice, but only for network drivers. Is there a generic
> solution, quirks are obviously not keeping people happy.
 
Since this is (normally) a property of the system, pci=nomsi is the
generic solution.

[...]
> Misc:
>   sound/pci/hda/hda_intel.c:MODULE_PARM_DESC(enable_msi, "Enable Message Signaled Interrupt (MSI)");
>   drivers/message/fusion/mptbase.c:MODULE_PARM_DESC(mpt_msi_enable_spi, " Enable MSI Support for SPI \
>   drivers/message/fusion/mptbase.c:MODULE_PARM_DESC(mpt_msi_enable_fc, " Enable MSI Support for FC \
>   drivers/message/fusion/mptbase.c:MODULE_PARM_DESC(mpt_msi_enable_sas, " Enable MSI Support for SAS \
>   drivers/net/myri10ge/myri10ge.c:MODULE_PARM_DESC(myri10ge_msi, "Enable Message Signalled Interrupts");
[...]

  drivers/net/sfc/efx.c:MODULE_PARM_DESC(interrupt_mode,
  drivers/net/sfc/efx.c-                 "Interrupt mode (0=>MSIX 1=>MSI 2=>legacy)");

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
