From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8519] New: NAT prerouting over tun interface
 broken
Date: Mon, 21 May 2007 13:13:43 -0700
Message-ID: <20070521131343.cbf3bcaa.akpm@linux-foundation.org>
References: <200705212005.l4LK5aJk029945@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, elendil@planet.nl
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38623 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759062AbXEUUQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 16:16:12 -0400
In-Reply-To: <200705212005.l4LK5aJk029945@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 May 2007 13:05:36 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8519
> 
>            Summary: NAT prerouting over tun interface broken
>     Kernel Version: 2.6.21.1
>             Status: NEW
>           Severity: normal
>              Owner: networking_netfilter-iptables@kernel-bugs.osdl.org
>          Submitter: elendil@planet.nl
> 
> 
> Most recent kernel where this bug did *NOT* occur: 2.6.20.7
> Distribution: Debian unstable
> Hardware Environment: EM64T (Pentium D) running amd64 kernel
> Software Environment: Debian unstable
> 
> Problem Description:
> I have the hercules s/390 emulator running on an EM64T host, both running 
> Debian unstable. I use a tun interface, a second IP address on eth0 and 
> iptables/nat so the emulator has it's own address on my local network.
> 
> With 2.6.21.1 on the host, networking between the emulator and the host system 
> is fine (I can ssh from the host into the emulator without problems), but 
> communication from the emulator with other boxes is broken. Other boxes also 
> don't see the emulator if I ping its external address.
> 
> If I ping another box on my LAN from the emulator while running wireshark on 
> the host, I can see that:
> - the echo request gets sent OK
> - the other box replies OK
> - the host receives the echo reply
> - but the tun interface never gets it.
> 
> If I boot the host with 2.6.20 everything works fine again.
> 
> Here is how the setup looks:
>         |---------------- host system --------------------|
>                                            |-- emulator --|
>             eth0              tun              ctc0
>  LAN  <---> 10.19.66.21   
>  LAN  <---> 10.19.66.92 <---> 10.19.92.2 <---> 10.19.92.1
>                          nat              P2P
> 
> The only active iptables rules are:
> iptables -t nat -A PREROUTING -d 10.19.66.92 \
>          -j DNAT --to-destination 10.19.92.1
> iptables -t nat -A POSTROUTING -s 10.19.92.1 \
>          -j SNAT --to-source 10.19.66.92
