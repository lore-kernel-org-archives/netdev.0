From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [Bugme-new] [Bug 13568] New: Intel e1000 4-port NIC - unable to
 communicate, slowly blinking
Date: Mon, 29 Jun 2009 16:32:23 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0906291623530.3700@jbrandeb-desk1.amr.corp.intel.com>
References: <bug-13568-10286@http.bugzilla.kernel.org/> <20090629160003.ea299eb5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tuharsky@misbb.sk" <tuharsky@misbb.sk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23607 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753308AbZF2XcX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 19:32:23 -0400
In-Reply-To: <20090629160003.ea299eb5.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Jun 2009, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Thu, 18 Jun 2009 13:45:38 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=13568
> > 
> >            Summary: Intel e1000 4-port NIC - unable to communicate, slowly
> >                     blinking
> >            Product: Drivers
> >            Version: 2.5
> >     Kernel Version: 2.6.30
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: Network
> >         AssignedTo: drivers_network@kernel-bugs.osdl.org
> >         ReportedBy: tuharsky@misbb.sk
> >         Regression: No
> > 
> > 
> > Hallo,
> > 
> > I have here Tyan GT20 (B2865G20S4H) barebone server with onboard GbE NICs
> > (Broadcom BCM5721 and Marvell 88E1111-CAA PHY).
> > 
> > I have installed PCI-E Intel__ PRO/1000 PT Quad Port Server Adapter
> > (EXPI9404PTBLK) to gain 6 ports altogether. This is the card:
> > 
> > http://www.intel.com/products/server/adapters/pro1000pt-quadport/pro1000pt-quadport-overview.htm
> > 
> > Now, with Debian 5.0 Lenny (distributional kernel 2.6.26), only the onboard
> > cards are functional. The Intel is also recognised by the kernel, is assigned
> > ports (eth2-5), however none of them works when connected to network. The NIC
> > is aware of plugging or un-plugging the cable (displays message on console),

that part is a good sign, probably indicating interrupts are working.

> > however no communication is ever performed, and the connected port just lazily
> > blinks.
> > 
> > After some rochades hard to reproduce (plugging, unplugging, configuring
> > interfaces, resetting etc), it even worked for few seconds, and then died out
> > again forever.
> > 
> > I have also compiled fresh 2.6.30 kernel, no advance however. Interesting, that
> > ifconfig always revails huge number of errors for the port.

errors even before traffic?

looking at the ifconfig output in the bug shows lots of rx_errors, 
indicating the counter went negative,

I wonder if you're having some kind of power issue.

can you do lspci -vvv after ifconfig shows errors?  also do 
ethtool -S eth2

do you get the arp/ping requests at the remote end? tcpdump on your remote 
and see if you get the packets.

you might want to (for debugging) try booting with pci=nomsi kernel option 
to disable MSI and see if that is related.

does tcpdump -i eth2 show any packets coming in?

there is a tool at e1000.sourceforge.net called ethregs that you can 
download/build and run, I would appreciate the output of that as well 
(probably gzipped)

Jesse
