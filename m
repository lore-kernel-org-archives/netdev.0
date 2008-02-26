From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10073] New: Just-small-enough packets in
 tunnels are silently eaten
Date: Mon, 25 Feb 2008 16:29:32 -0800
Message-ID: <20080225162932.67b38f1b.akpm@linux-foundation.org>
References: <bug-10073-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, sgunderson@bigfoot.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:43992 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757418AbYBZAa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 19:30:27 -0500
In-Reply-To: <bug-10073-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Feb 2008 09:17:14 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10073
> 
>            Summary: Just-small-enough packets in tunnels are silently eaten
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.23 (mainline), 2.6.25-rc2 (mainline), 2.6.18-6-amd64
>                     (Debian
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: sgunderson@bigfoot.com
> 
> 
> Hi,
> 
> This has been broken for quite a while, but I haven't gotten around to debug it
> until now.
> 
> I have an IPv6-in-IPv4 tunnel between two points, both with MTU 1500 on the
> regular v4 network. (I've verified that I can indeed send 1500-byte packets and
> fragments over IPv4 from the two points.) By default, Linux assigns MTU 1480 to
> this tunnel.
> 
> However, if I try to ping -s 5000 from one side of the tunnel to the other, I
> get
> first "Packet too big, mtu=1480" and then on the next packet (when the machine
> tries to send 1480-byte fragments) "Packet too big, mtu=1472". After that, the
> packet goes through.
> 
> However, in some cases it seems I do not seem to get the "Packet too big" ICMP
> at all. In particular, if I change to a GRE tunnel (where the default MTU is
> 1476), and send in 1476-byte packets, they are just eaten. They clearly go into
> the GRE tunnel (according to tcpdump), but no IPv4 packets ever go out on the
> other side, and no ICMPs are sent back. (There's no iptables rules on the
> router in question, nor any relevant sysctl settings except that IPv6
> forwarding is of course turned on.) If I lower MTU on the interfaces to 1468,
> everything seems to work just fine. (I cannot change the MTU of a regular ipip
> tunnel, so it's impossible for me to check whether a lower MTU would have fixed
> the issues for those as well, but it seems reasonable.)
> 
> Any idea where the extra eight bytes go? Is there some inner layer of
> encapsulation in the kernel (adding eight bytes internally) that I've missed?
> 
