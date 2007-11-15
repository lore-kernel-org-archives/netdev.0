From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 9384] New: Appletalk packets are delivered to
 the last interface FD_SET
Date: Thu, 15 Nov 2007 15:49:35 -0800 (PST)
Message-ID: <20071115.154935.96540711.davem@davemloft.net>
References: <bug-9384-10286@http.bugzilla.kernel.org/>
	<20071115021219.e5c71556.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	trs80@ucc.asn.au, acme@ghostprotocols.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56682
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753275AbXKOXtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 18:49:36 -0500
In-Reply-To: <20071115021219.e5c71556.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 15 Nov 2007 02:12:19 -0800

> > Most recent kernel where this bug did not occur: 2.6.10. Maybe 2.6.15? It was
> > in 2.6.18 along with bug 7421 which caused me to disable netatalk until now.
> > Distribution: Debian etch (4.0)
> > Hardware Environment: Pentium 4 2.8GHz, HT off, Intel D865GLC motherboard,
> > 256MB RAM, onboard Intel GigE, PCI Intel e100.
> > Software Environment: Netatalk 2.0.3, ipset patch for iptables and kernel
> > Problem Description: Appletalk packets appear to come from the wrong interface,
> > specifically the last one FD_SET. Using wireshark I see Appletalk rtmp packets
> > arrive from the upstream router on eth1 (the e100). Netatalk then reports the
> > packet as having arrived on eth0.3, which is the only other appletalk enabled
> > interface, and prints "rtmp_packet interface mismatch" because the packet
> > appears to come from the wrong interface.
> > 
> > I'm fairly sure it's the kernel doing it, because wireshark is listening on
> > eth1 and shows the packet from the upstream router's MAC address and DDP
> > address, then the debug code in atalkd immediately after the recvfrom prints
> > the ifr_name which is eth0.3. Also netatalk 2.0.3 was released over 2 years
> > ago, so the only code that's changed is the kernel.
> > 
> > Enabling appletalk on eth0.2 clarifies the problem - packets are delivered to
> > fds belonging to the last interface FD_SET. Reordering the interfaces also
> > shows this, as in the config file changing the order of the interfaces changes
> > the order they're looped through for FD_SET.
> > 
> > Steps to reproduce: Set up a multi-interface netatalk config and watch for
> > rtmp_packet interface mismatch messages. I added a bunch of log statements to
> > debug this, the most useful places to put them are at the end of setaddr() and
> > after the select() in main().
> > 
> > The machine is a router, so I have to minimise the downtime of testing
> > different kernel versions. I am happy to instrument atalkd or provide packet
> > captures.

I suspect there is some issue with the ordering of the atalk
interface list which is causing this.

Arnaldo, can you please take a look at this?

Thanks.
