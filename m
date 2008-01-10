From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9721] New: wake on lan fails with sky2 module
Date: Wed, 9 Jan 2008 20:52:10 -0800
Message-ID: <20080109205210.1f8a83bb@deepthought>
References: <bug-9721-10286@http.bugzilla.kernel.org/>
	<20080109160300.304ec687.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-acpi@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, supersud501@yahoo.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:40474 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754436AbYAJEy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 23:54:27 -0500
In-Reply-To: <20080109160300.304ec687.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Jan 2008 16:03:00 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Wed,  9 Jan 2008 13:05:34 -0800 (PST)
> bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=9721
> > 
> >            Summary: wake on lan fails with sky2 module
> >            Product: ACPI
> >            Version: 2.5
> >      KernelVersion: 2.6.24-rc7
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Power-Sleep-Wake
> >         AssignedTo: acpi_power-sleep-wake@kernel-bugs.osdl.org
> >         ReportedBy: supersud501@yahoo.de
> 
> This post-2.6.23 regression was assigned to ACPI but is quite possibly a
> net driver problem?
> 
> > 
> > Latest working kernel version: 2.6.23.12
> > Earliest failing kernel version: 2.6.24-rc6 (not tested earlier kernel,
> > 2.6.24-rc7 still failing)
> > Distribution: Ubuntu 8.04 (but Kernel build from Kernel.org and system modifiet
> > to make wake on lan work, i.e. network cards are not shutted down on poweroff)
> > Hardware Environment: Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit
> > Ethernet Controller (rev 20) onboard Asus P5W DH motherboard, uses module SKY2
> > Software Environment:
> > Problem Description:
> > 
> > When enabling wake on lan with: 'ethtool -s eth0 wol' i get the following
> > status:
> > 
> > 21:56:29 ~ # sudo ethtool eth0
> > Settings for eth0:
> >         Supported ports: [ TP ]
> >         Supported link modes:   10baseT/Half 10baseT/Full 
> >                                 100baseT/Half 100baseT/Full 
> >                                 1000baseT/Half 1000baseT/Full 
> >         Supports auto-negotiation: Yes
> >         Advertised link modes:  10baseT/Half 10baseT/Full 
> >                                 100baseT/Half 100baseT/Full 
> >                                 1000baseT/Half 1000baseT/Full 
> >         Advertised auto-negotiation: Yes
> >         Speed: 100Mb/s
> >         Duplex: Full
> >         Port: Twisted Pair
> >         PHYAD: 0
> >         Transceiver: internal
> >         Auto-negotiation: on
> >         Supports Wake-on: pg
> >         Wake-on: g    <---- wol enabled
> >         Current message level: 0x000000ff (255)
> >         Link detected: yes
> > 
> > but after shutting down the pc doesn't wake up when magic packet is sent.
> > 
> > the status lights of the network card are still on (so the card seems to be
> > online).
> > 
> > same system with only changed kernel to 2.6.23.12 and same procedure like
> > above: wake on lan works.
> > 
> > Steps to reproduce: enable wol on your network card using SKY2 module and it
> > doesn't work too?
> > 
> > if you need more information, just tell me, it's my first bug report.
> > regards
> > 


Wake from power off works on 2.6.24-rc7 for me.
Wake from suspend doesn't because Network Manager, HAL, or some other
user space tool gets confused.

I just rechecked it with Fujitsu Lifebook, which has sky2 (88E8055).
There many variations of this chip, and it maybe chip specific problem
or ACPI/BIOS issues.  If you don't enable Wake on Lan in BIOS, the
driver can't do it for you. Also, check how you are shutting down.

Also since the device has to restart the PHY, it could be a switch
issue if you have some fancy pants switch doing intrusion detection
or something, but I doubt that.

Is it a clean or fast shutdown, most distributions mark network
devices as down on shutdown, but if the distribution does something 
stupid like remove the driver module, then the driver is unable to setup Wake On Lan.
The wake on lan setup is done in one place in the driver, add
a printk to see if it is ever called.


-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
