From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 00/13] drivers: hv: kvp
Date: Mon, 2 Jul 2012 20:57:21 +0100
Message-ID: <20120702195721.GE1894@decadent.org.uk>
References: <20120621224737.GA5933@kroah.com>
 <426367E2313C2449837CD2DE46E7EAF9155EC47A@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20120622132547.GA2639@kroah.com>
 <426367E2313C2449837CD2DE46E7EAF9155ED14D@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20120626213954.GA4840@kroah.com>
 <426367E2313C2449837CD2DE46E7EAF9155ED64A@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20120626222205.GA5948@kroah.com>
 <426367E2313C2449837CD2DE46E7EAF9155ED68D@SN2PRD0310MB382.namprd03.prod.outlook.com>
 <20120628142340.GA21537@aepfle.de>
 <426367E2313C2449837CD2DE46E7EAF9155EF399@SN2PRD0310MB382.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf Hering <olaf@aepfle.de>, Greg KH <gregkh@linuxfoundation.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"virtualization@lists.osdl.org" <virtualization@lists.osdl.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: KY Srinivasan <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <426367E2313C2449837CD2DE46E7EAF9155EF399@SN2PRD0310MB382.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 02, 2012 at 03:22:25PM +0000, KY Srinivasan wrote:
> 
> 
> > -----Original Message-----
> > From: Olaf Hering [mailto:olaf@aepfle.de]
> > Sent: Thursday, June 28, 2012 10:24 AM
> > To: KY Srinivasan
> > Cc: Greg KH; apw@canonical.com; devel@linuxdriverproject.org;
> > virtualization@lists.osdl.org; linux-kernel@vger.kernel.org
> > Subject: Re: [PATCH 00/13] drivers: hv: kvp
> > 
> > On Tue, Jun 26, KY Srinivasan wrote:
> > 
> > > > From: Greg KH [mailto:gregkh@linuxfoundation.org]
> > > > The fact that it was Red Hat specific was the main part, this should be
> > > > done in a standard way, with standard tools, right?
> > >
> > > The reason I asked this question was to make sure I address these
> > > issues in addition to whatever I am debugging now. I use the standard
> > > tools and calls to retrieve all the IP configuration. As I look at
> > > each distribution the files they keep persistent IP configuration
> > > Information is different and that is the reason I chose to start with
> > > RedHat. If there is a standard way to store the configuration, I will
> > > do that.
> > 
> > 
> > KY,
> > 
> > instead of using system() in kvp_get_ipconfig_info and kvp_set_ip_info,
> > wouldnt it be easier to call an external helper script which does all
> > the distribution specific work? Just define some API to pass values to
> > the script, and something to read values collected by the script back
> > into the daemon.
> 
> On the "Get" side I mostly use standard commands/APIs to get all the information:
> 
> 1) IP address information and subnet mask: getifaddrs()
> 2) DNS information:  Parsing /etc/resolv.conf
> 3) /sbin/ip command for all the routing information

If you're interested in the *current* configuration then (1) and (3)
are OK but you should really use the rtnetlink API.

However, I suspect that Hyper-V assumes that current and persistent
configuration are the same thing, which is obviously not true in
general on Linux.  But if NetworkManager is running then you can
assume they are.

> 4)  Parse /etc/sysconfig/network-scripts/ifcfg-ethx for boot protocol
> 
> As you can see, all but the boot protocol is gathered using the "standard distro
> independent mechanisms. I was looking at NetworkManager cli and it looks
> like I could gather all the information except the boot protocol information. I am 
> not sure how to gather the boot protocol information in a distro independent fashion.
> 
> On the SET side, I need to persistently store the settings in an appropriate configuration
> file and flush these settings down so that the interface is appropriately configured. It is here
> that I am struggling to find a distro independent way of doing things. It would be great if I can
> use NetworkManager cli (nmcli) to accomplish this. Any help here would be greatly appreciated.
[...]

What was wrong with the NetworkManager D-Bus API I pointed you at?
I don't see how it makes sense to use nmcli as an API.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
