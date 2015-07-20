From: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Subject: RE: [PATCH RFC 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Mon, 20 Jul 2015 12:18:52 +0000
Message-ID: <BL2PR03MB5456302C77FAEC1AC60669CE6850@BL2PR03MB545.namprd03.prod.outlook.com>
References: <1427905196-27778-1-git-send-email-madalin.bucur@freescale.com>
	 <1437378870.10831.12.camel@transmode.se>
 <1437379026.10831.14.camel@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437379026.10831.14.camel@transmode.se>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joakim

> -----Original Message-----
> From: Joakim Tjernlund [mailto:joakim.tjernlund@transmode.se]
> Sent: Monday, July 20, 2015 10:57 AM
> To: linuxppc-dev@lists.ozlabs.org; netdev@vger.kernel.org; Bucur Madalin-
> Cristian-B32716
> Cc: linux-kernel@vger.kernel.org
> Subject: Re: [PATCH RFC 02/10] dpaa_eth: add support for DPAA Ethernet
> 
> On Mon, 2015-07-20 at 09:54 +0200, Joakim Tjernlund wrote:
> > On Wed, 2015-04-01 at 19:19 +0300, Madalin Bucur wrote:
> > > This introduces the Freescale Data Path Acceleration Architecture
> > > (DPAA) Ethernet driver (dpaa_eth) that builds upon the DPAA QMan,
> > > BMan, PAMU and FMan drivers to deliver Ethernet connectivity on
> > > the Freescale DPAA QorIQ platforms.
> > >
> > > Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> > > ---
> > ....
> > > +	snprintf(net_dev->name, IFNAMSIZ, "fm%d-mac%d",
> > > +		 dpa_mac_fman_index_get(pdev),
> > > +		 dpa_mac_hw_index_get(pdev));
> >
> > Should ethernet drivers dictate interface name in user space nowadays?
> > I would prefer if you didn't.

The preformatted interface name was thought as a helper for quick interface
identification. It also ensures constant naming of the interfaces, i.e. if you
add/remove PCI network cards. One can make use of udev rules to override
default interface names ("eth%d") in userspace.

Another reason for using this is that the interface name was also used for the
debugfs file name and when compiling dpaa_eth as a module there was a
problem with udev concurrently renaming interfaces from eth0 to something
like fmx-macy, making the next probed DPAA interface temporarily get the
eth0 name (before being renamed fmx-macw). Subsequently,
the debugfs_create_file(net_dev->name,...) call failed because of duplicated
names.

If this is considered more of a bug than a feature, I can remove it and only change
the naming of the debugfs entries to avoid the udev issue.

> > I am trying these patches on a custom T1042 board using Linux 4.1 but
> > I cannot get Fixed PHY to work:
> > libphy: PHY fixed-0:00 not found
> > fsl_dpa dpaa-ethernet.2 eth2: Could not connect to PHY fixed-0:00
> > fsl_dpa dpaa-ethernet.2 eth2: init_phy() = -19
> >
> > Not sure what I have missed here, any ideas?
> 
> I meant I am using
> http://git.freescale.com/git/cgit.cgi/ppc/upstream/linux.git/
> on top of 4.1
> 
>  Jocke

Please make sure you have CONFIG_FIXED_PHY=y in your .config.
Can you please share the device tree part where you've added the fixed-link entry?

Madalin
