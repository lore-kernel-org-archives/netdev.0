From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9384] New: Appletalk packets are delivered to
 the last interface FD_SET
Date: Thu, 15 Nov 2007 02:12:19 -0800
Message-ID: <20071115021219.e5c71556.akpm@linux-foundation.org>
References: <bug-9384-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, trs80@ucc.asn.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46851 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755913AbXKOKMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 05:12:42 -0500
In-Reply-To: <bug-9384-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(switching to email for netdev - please repond via emailed reply-to-all, not
via the bugzilla UI)

On Thu, 15 Nov 2007 01:56:07 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9384
> 
>            Summary: Appletalk packets are delivered to the last interface
>                     FD_SET
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.21.3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: trs80@ucc.asn.au
> 
> 
> Most recent kernel where this bug did not occur: 2.6.10. Maybe 2.6.15? It was
> in 2.6.18 along with bug 7421 which caused me to disable netatalk until now.
> Distribution: Debian etch (4.0)
> Hardware Environment: Pentium 4 2.8GHz, HT off, Intel D865GLC motherboard,
> 256MB RAM, onboard Intel GigE, PCI Intel e100.
> Software Environment: Netatalk 2.0.3, ipset patch for iptables and kernel
> Problem Description: Appletalk packets appear to come from the wrong interface,
> specifically the last one FD_SET. Using wireshark I see Appletalk rtmp packets
> arrive from the upstream router on eth1 (the e100). Netatalk then reports the
> packet as having arrived on eth0.3, which is the only other appletalk enabled
> interface, and prints "rtmp_packet interface mismatch" because the packet
> appears to come from the wrong interface.
> 
> I'm fairly sure it's the kernel doing it, because wireshark is listening on
> eth1 and shows the packet from the upstream router's MAC address and DDP
> address, then the debug code in atalkd immediately after the recvfrom prints
> the ifr_name which is eth0.3. Also netatalk 2.0.3 was released over 2 years
> ago, so the only code that's changed is the kernel.
> 
> Enabling appletalk on eth0.2 clarifies the problem - packets are delivered to
> fds belonging to the last interface FD_SET. Reordering the interfaces also
> shows this, as in the config file changing the order of the interfaces changes
> the order they're looped through for FD_SET.
> 
> Steps to reproduce: Set up a multi-interface netatalk config and watch for
> rtmp_packet interface mismatch messages. I added a bunch of log statements to
> debug this, the most useful places to put them are at the end of setaddr() and
> after the select() in main().
> 
> The machine is a router, so I have to minimise the downtime of testing
> different kernel versions. I am happy to instrument atalkd or provide packet
> captures.
> 

