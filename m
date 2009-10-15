From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [BUILD-FAILURE] next-20091015 - vbus_enet driver breaks with
 allmodconfig
Date: Thu, 15 Oct 2009 11:54:11 -0700
Message-ID: <20091015115411.5b556047.randy.dunlap@oracle.com>
References: <20091015152538.74a1cb15.sfr@canb.auug.org.au>
	<20091015104852.GA6740@linux.vnet.ibm.com>
	<4AD6CD940200005A00056857@sinclair.provo.novell.com>
	<4AD75E60.4020306@gmail.com>
	<20091015114210.65e1be72.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	sfr@canb.auug.org.au, greg@kroah.com, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>,
	Gregory Haskins <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760025AbZJOSzc@vger.kernel.org>
In-Reply-To: <20091015114210.65e1be72.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Oct 2009 11:42:10 -0700 Randy Dunlap wrote:

> On Thu, 15 Oct 2009 13:39:44 -0400 Gregory Haskins wrote:
> 
> > Gregory Haskins wrote:
> > >>>> On 10/15/2009 at  6:48 AM, in message
> > > <20091015104852.GA6740@linux.vnet.ibm.com>, Kamalesh Babulal
> > > <kamalesh@linux.vnet.ibm.com> wrote: 
> > >> Hi Gregory,
> > >>
> > >> 	While building next-20091015 with allmodconfig on the powerpc
> > >> vbus-enet driver breaks
> > > 
> > > Hi Kamalesh,
> > > 
> > > I'll take a look at this and get a fix submitted today.
> > > 
> > > Kind Regards,
> > > -Greg
> > > 
> > >> MODPOST 2492 modules
> > >> ERROR: ".vbus_driver_register" [drivers/net/vbus-enet.ko] undefined!
> > >> ERROR: ".vbus_driver_unregister" [drivers/net/vbus-enet.ko] undefined!
> > >> ERROR: ".vbus_driver_ioq_alloc" [drivers/net/vbus-enet.ko] undefined!
> > >>
> > >> CONFIG_VBUS_ENET=m
> > >> CONFIG_VBUS_ENET_DEBUG=y
> > >> CONFIG_VBUS_PROXY=n
> > 
> > Hi Kamalesh,
> > 
> > I am having difficulty reproducing the problem.  When I look at the
> > Kconfig, I see that VBUS_ENET has a "select VBUS_PROXY" as I would
> > expect.  Additionally, if I run allmodconfig I can confirm that I get
> > VBUS_ENET=m, VBUS_PROXY=y:
> 
> Greg,
> 
> Did you try to reproduce it with the ppc64 config file?
> allmodconfig on what arch?
> 
> I think the problem is that arch/x86/Kconfig says:
> 
> source "drivers/vbus/Kconfig"
> 
> and that should actually be in drivers/Kconfig, so that it applies
> to ppc64 et al, not just x86.
> 

OTOH, drivers/vbus/pci-bridge.c uses create_irq(), which is implemented
only on x86 and ia64 and one ARM platform, so all of this ppc testing
seems to be invalid...  ?


> 
> > ghaskins@dev:~/sandbox/git/fabric/linux-2.6-next> rm .config
> > ghaskins@dev:~/sandbox/git/fabric/linux-2.6-next> make allmodconfig
> > scripts/kconfig/conf -m arch/x86/Kconfig
> > #
> > # configuration written to .config
> > #
> > ghaskins@dev:~/sandbox/git/fabric/linux-2.6-next> grep -i vbus .config
> > CONFIG_VBUS_PROXY=y
> > CONFIG_VBUS_PCIBRIDGE=y
> > CONFIG_VBUS_ENET=m
> > CONFIG_VBUS_ENET_DEBUG=y
> > CONFIG_USB_GADGET_VBUS_DRAW=2
> > CONFIG_USB_GPIO_VBUS=m
> > 
> > I am not sure how your environment could have generated the VBUS_PROXY=n
> > outcome.  Does anyone have any ideas?
> > 
> > -Greg


---
~Randy
