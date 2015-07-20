From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH RFC 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Mon, 20 Jul 2015 12:46:37 +0000
Message-ID: <1437396397.10831.31.camel@transmode.se>
References: <1427905196-27778-1-git-send-email-madalin.bucur@freescale.com>
	 <1437378870.10831.12.camel@transmode.se>
	 <1437379026.10831.14.camel@transmode.se>
	 <BL2PR03MB5456302C77FAEC1AC60669CE6850@BL2PR03MB545.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"madalin.bucur@freescale.com" <madalin.bucur@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BL2PR03MB5456302C77FAEC1AC60669CE6850@BL2PR03MB545.namprd03.prod.outlook.com>
Content-Language: en-US
Content-ID: <44CC493FB349494FAF6EE6F761A4E1B8@transmode.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-07-20 at 12:18 +0000, Madalin-Cristian Bucur wrote:
> Hi Joakim
> 
> > -----Original Message-----
> > From: Joakim Tjernlund [mailto:joakim.tjernlund@transmode.se]
> > Sent: Monday, July 20, 2015 10:57 AM
> > To: linuxppc-dev@lists.ozlabs.org; netdev@vger.kernel.org; Bucur Madalin-
> > Cristian-B32716
> > Cc: linux-kernel@vger.kernel.org
> > Subject: Re: [PATCH RFC 02/10] dpaa_eth: add support for DPAA Ethernet
> > 
> > On Mon, 2015-07-20 at 09:54 +0200, Joakim Tjernlund wrote:
> > > On Wed, 2015-04-01 at 19:19 +0300, Madalin Bucur wrote:
> > > > This introduces the Freescale Data Path Acceleration Architecture
> > > > (DPAA) Ethernet driver (dpaa_eth) that builds upon the DPAA QMan,
> > > > BMan, PAMU and FMan drivers to deliver Ethernet connectivity on
> > > > the Freescale DPAA QorIQ platforms.
> > > > 
> > > > Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> > > > ---
> > > ....
> > > > +	snprintf(net_dev->name, IFNAMSIZ, "fm%d-mac%d",
> > > > +		 dpa_mac_fman_index_get(pdev),
> > > > +		 dpa_mac_hw_index_get(pdev));
> > > 
> > > Should ethernet drivers dictate interface name in user space nowadays?
> > > I would prefer if you didn't.
> 
> The preformatted interface name was thought as a helper for quick interface
> identification. It also ensures constant naming of the interfaces, i.e. if you
> add/remove PCI network cards. One can make use of udev rules to override
> default interface names ("eth%d") in userspace.

I am not well versed in ethernet interface naming but I think you are just creating
another name space here. To me one either have the old eth%d names or let udev do
the naming so there is some order w.r.t interface naming.

I also find it handy to be able to control which I/F is eth0 etc. just by changing
the order they are listed in the device tree. This makes our application happy :)

> 
> Another reason for using this is that the interface name was also used for the
> debugfs file name and when compiling dpaa_eth as a module there was a
> problem with udev concurrently renaming interfaces from eth0 to something
> like fmx-macy, making the next probed DPAA interface temporarily get the
> eth0 name (before being renamed fmx-macw). Subsequently,
> the debugfs_create_file(net_dev->name,...) call failed because of duplicated
> names.
> 
> If this is considered more of a bug than a feature, I can remove it and only change
> the naming of the debugfs entries to avoid the udev issue.

Perhaps netdev list can advise?

 Jocke