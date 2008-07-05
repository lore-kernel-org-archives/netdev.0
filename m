From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [Bugme-new] [Bug 11036] New: atl1 tx busy and hw csum wrong
Date: Sat, 5 Jul 2008 15:41:48 -0500
Message-ID: <20080705154148.43f6e2a7@osprey.hogchain.net>
References: <bug-11036-10286@http.bugzilla.kernel.org/>
	<20080705122348.e9b55b57.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	scurippio@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost05.isp.att.net ([207.115.11.55]:43085 "EHLO
	fmailhost05.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537AbYGEUmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2008 16:42:00 -0400
In-Reply-To: <20080705122348.e9b55b57.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 5 Jul 2008 12:23:48 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> (switched to email.  Please respond via emailed reply-to-all, not via
> the bugzilla web interface).
> 
> On Sat,  5 Jul 2008 03:54:15 -0700 (PDT)
> bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=11036
> > 
> >            Summary: atl1 tx busy and hw csum wrong
> >            Product: Drivers
> >            Version: 2.5
> >      KernelVersion: 2.6.24-1-amd64
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: low
> >           Priority: P1
> >          Component: Network
> >         AssignedTo: jgarzik@pobox.com
> >         ReportedBy: scurippio@gmail.com
> > 
> > 
> > Latest working kernel version:
> > Earliest failing kernel version:
> > Distribution: Debian amd64 lenny
> > Hardware Environment: Ethernet controller: Attansic Technology
> > Corp. L1 Gigabit Ethernet Adapter (rev b0)
> > Software Environment: atl1 module
> > Problem Description:
> > dmesg get flooded on irregular intervals by
> > atl1 0000:01:00.0: tx busy

This is a KERN_DEBUG advisory message indicating you ran out of transmit
descriptors.  This can happen under heavy load.  In current mainline
this message is filtered by netif_msg_tx_queued, and by default the
message will not be issued; it can be turned on using ethtool -s ethX
msglvl <value>.

> > and
> > atl1 0000:01:00.0: hw csum wrong, pkt_flag:1600, err_flag:80

This is also a KERN_DEBUG message, and it indicates that a received
packet was too short.

pkt_flag:1600 - ipv4, tcp, packet with error
err_flag:80 - runt packet

In current mainline this message is filtered by netif_msg_rx_err, so it
too can be controlled with ethtool (and will also be off by default).

To get rid of the messages in your 2.6.24 kernel, you might try reducing
the loglevel to exclude KERN_DEBUG messages.


