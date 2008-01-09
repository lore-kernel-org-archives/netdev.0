From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new]  [Bug 9719] New: when a system is configured as a
 bridge, and at the same time configured to have multipath weighted route,
 with one leg goes thru NAT and another without NAT, the nat path will
 intermittently get packets leaking out using internal IP without being
 SNAT-ted
Date: Wed, 9 Jan 2008 15:28:13 -0800
Message-ID: <20080109152813.83fb8168.akpm@linux-foundation.org>
References: <bug-9719-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: mingching.tiew@redtone.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34759 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754156AbYAIX2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 18:28:46 -0500
In-Reply-To: <bug-9719-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed,  9 Jan 2008 11:55:50 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9719
> 
>            Summary: when a system is configured as a bridge, and at the same
>                     time configured to have multipath weighted route, with
>                     one leg goes thru NAT and another without NAT, the nat
>                     path will intermittently get packets leaking out using
>                     internal IP without being SNAT-ted
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.22.15 and 2.6.23
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Netfilter/Iptables
>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>         ReportedBy: mingching.tiew@redtone.com
> 
> 
> Latest working kernel version: 2.6.23
> Earliest failing kernel version: 2.6.22.15

This doesn't make sense.  What we're trying to ask here (and we've been
unable to find a pair of questions which 100% of reporters can successfully
answer) is whether this is a regression, and in which kernel release did we
regress?

In other words: did we break it, and if so, when did we break it?

> Distribution: iptables 1.4.0 was used with kernel 2.6.23 and iptables 1.3.8
> with 2.6.22.15
> Hardware Environment: 3 interfaces, 2 interfaces bridged to form br0, and
> another connects to internet using pppoe.
> Software Environment: bridge, multipath routing
> Problem Description: when a system is configured as a bridge with IP assigned
> to br0 interface, and at the same time it is configured to have multipath
> weighted default route, and one of the default route is NAT-ed and another of
> the default route is not NAT-ed, then it is NAT-ed interface will occasionally
> get packets leaking out to it with packets with private IPs.
> 
> Steps to reproduce: 
> 1) setup the bridge interface and assign an IP to it 
> 2) setup an default gateway on side B of the bridge ( without NAT ) and default
> route the bridge to this gateway. 
> 3) Setup a client on side A of the bridge and default route to the bridge br0
> interface.
> 4) Start ping'ing an internet site, for example www.google.com from the client.
>    Run the ping continuously, for example :-
>          while true
>          do
>             ping -c 1 www.google.com
>             sleep 1
>          done
> 5) after successfully and consistently getting a ping response from the
> www.google.com, on the bridge system start up another uplink to the internet,
> but this uplink is SNAT-ed 
> 
>        ( eg iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE ) 
> 
> 6) verify and make sure that the second uplink is working.
> 7) change the default route on the bridge to multipath weighted route with
> equal weight on both the uplinks.
> 8) sniff the NAT-ed inteface for packets coming in from the LAN client.
> Occasionallly packets with private IP leaks to the NAT-ed interface.
> 

