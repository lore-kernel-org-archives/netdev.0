From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH] e100: Don't enable WoL by default on
	Toshiba devices
Date: Thu, 15 Jan 2015 16:18:07 +0100
Message-ID: <201501151618.07434.linux@rainbow-software.org>
References: <1415832445-9524-1-git-send-email-linux@rainbow-software.org>
	<201501151440.32159.linux@rainbow-software.org>
	<1421333621.2632.19.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1421333621.2632.19.camel@jtkirshe-mobl>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thursday 15 January 2015, Jeff Kirsher wrote:
> On Thu, 2015-01-15 at 14:40 +0100, Ondrej Zary wrote:
> > On Thursday 13 November 2014, Jeff Kirsher wrote:
> > > On Wed, 2014-11-12 at 18:18 -0500, David Miller wrote:
> > > > From: Ondrej Zary <linux@rainbow-software.org>
> > > > Date: Wed, 12 Nov 2014 23:47:25 +0100
> > > >
> > > > > Enabling WoL on some Toshiba laptops (such as Portege R100)
> >
> > causes
> >
> > > > > battery drain after shutdown (WoL is active even on battery).
> >
> > These
> >
> > > > > laptops have the WoL bit set in EEPROM ID, causing e100 driver
> >
> > to
> >
> > > > > enable WoL by default.
> > > > >
> > > > > Check subsystem vendor ID and if it's Toshiba, don't enable WoL
> >
> > by
> >
> > > > > default from EEPROM settings.
> > > > >
> > > > > Fixes
> >
> > https://bugs.launchpad.net/ubuntu/+source/linux/+bug/110784
> >
> > > > > Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> > > >
> > > > Jeff, are you gonna pick this up?
> > >
> > > Yes, sorry I did not catch it earlier.
> >
> > What happened to this patch? I don't see it in net.git or
> > net-next.git
> > (checked both davem's and jkirsher's)
>
> Sorry, I thought I had replied with a NAK on this patch after further
> review of the changes.
>
> We don't fix BIOS issues in the driver especially regarding feature
> enablement like WoL.  We would end up with dozens of these kinds of fixes
> if we to allow this.
>
> You should go back to the OEM and ask for a BIOS update to resolve this or
> configure udev so that ethtool disables WoL.

This is not a BIOS bug. When the machine is powered off in BIOS (or GRUB), 
everything is OK.

The bug is that e100 driver enables WoL based on some bit in EEPROM that 
happens to be set on at least some Toshiba laptops and user has no way to 
change it. Windows driver does not do this. Other Linux ethernet drivers 
don't do this. When user wants WoL, (s)he enables it in BIOS and OS. Maybe 
this (mis)feature should be removed from the driver.

-- 
Ondrej Zary

------------------------------------------------------------------------------
New Year. New Location. New Benefits. New Data Center in Ashburn, VA.
GigeNET is offering a free month of service with a new server in Ashburn.
Choose from 2 high performing configs, both with 100TB of bandwidth.
Higher redundancy.Lower latency.Increased capacity.Completely compliant.
http://p.sf.net/sfu/gigenet
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
