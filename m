From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH] r8152: Add support for setting MAC to system's Auxiliary
 MAC address
Date: Thu, 2 Jun 2016 01:54:47 +0000
Message-ID: <047b23349a674f1fa9905f2f3ab0cec5@ausx13mpc124.AMER.DELL.COM>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
 <20160601222703.GJ31982@lunn.ch>
 <b1ca1d7d97ee4abb9691963488a27480@ausx13mpc124.AMER.DELL.COM>
 <20160601230651.GA29439@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <hayeswang@realtek.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <pali.rohar@gmail.com>,
	<anthony.wong@canonical.com>
To: <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160601230651.GA29439@kroah.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Sent: Wednesday, June 1, 2016 6:07 PM
> To: Limonciello, Mario <Mario_Limonciello@Dell.com>
> Cc: andrew@lunn.ch; hayeswang@realtek.com; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org; linux-usb@vger.kernel.org; pali.rohar@gmail.com;
> anthony.wong@canonical.com
> Subject: Re: [PATCH] r8152: Add support for setting MAC to system's Auxiliary
> MAC address
> 
> On Wed, Jun 01, 2016 at 10:31:52PM +0000, Mario_Limonciello@Dell.com
> wrote:
> > > -----Original Message-----
> > > From: Andrew Lunn [mailto:andrew@lunn.ch]
> > > Sent: Wednesday, June 1, 2016 5:27 PM
> > > To: Limonciello, Mario <Mario_Limonciello@Dell.com>
> > > Cc: hayeswang@realtek.com; LKML <linux-kernel@vger.kernel.org>;
> > > Netdev <netdev@vger.kernel.org>; Linux USB
> > > <linux-usb@vger.kernel.org>; pali.rohar@gmail.com;
> > > anthony.wong@canonical.com
> > > Subject: Re: [PATCH] r8152: Add support for setting MAC to system's
> > > Auxiliary MAC address
> > >
> > > On Wed, Jun 01, 2016 at 04:50:44PM -0500, Mario Limonciello wrote:
> > > > Dell systems with Type-C ports have support for a persistent
> > > > system specific MAC address when used with Dell Type-C docks and
> dongles.
> > > > This means a dock plugged into two different systems will show
> > > > different (but persistent) MAC addresses.  Dell Type-C docks and
> > > > dongles use the
> > > > r8152 driver.
> > > >
> > > > This information for the system's persistent MAC address is burned
> > > > in when the HW is built and avilable under _SB\AMAC in the DSDT at
> runtime.
> > > >
> > > > More information about the technology is available here:
> > > > http://www.dell.com/support/article/us/en/04/SLN301147
> > > >
> > > > Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
> > > > ---
> > > >  drivers/net/usb/Kconfig |  1 +
> > > >  drivers/net/usb/r8152.c | 37
> > > +++++++++++++++++++++++++++++++++++++
> > > >  2 files changed, 38 insertions(+)
> > > >
> > > > diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> > > > index
> > > > cdde590..c320930 100644
> > > > --- a/drivers/net/usb/Kconfig
> > > > +++ b/drivers/net/usb/Kconfig
> > > > @@ -98,6 +98,7 @@ config USB_RTL8150  config USB_RTL8152
> > > >  	tristate "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
> > > >  	select MII
> > > > +	depends on ACPI
> > >
> > > Hi Mario
> > >
> > > That seems a bit heavy handed. What about ARM or MIPS machines which
> > > don't use ACPI but do have USB ports where i could plug in a USB
> > > dongle with this chipset.
> > >
> > > I think it would be better to make use of ACPI if it is available,
> > > but don't require it in order the build the driver.
> > >
> > >       Andrew
> >
> > Hi Andrew,
> >
> > Thanks for that feedback.  I'll adjust that to look for CONFIG_ACPI in
> > the code instead in V2 after I get some additional comments for the
> > implementation.
> 
> No need to do that, the acpi functions should be "stubbed out" if that option is
> not enabled, right?  You don't want #ifdefs in .c code if at all possible.
> 
> thanks,
> 
> greg k-h

Thanks, yeah I do see them stubbed out, will skip #ifdefs and just drop the Kconfig dependency on ACPI.
