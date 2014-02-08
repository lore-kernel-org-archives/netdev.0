From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 FIB related crash with MACVLANs in 3.9.11+ kernel.
Date: Sat, 8 Feb 2014 18:23:10 +0100
Message-ID: <20140208172310.GF16198@order.stressinduktion.org>
References: <52EFFE20.5080500@candelatech.com> <20140203220323.GB17999@order.stressinduktion.org> <52F012FF.9030105@candelatech.com> <52F65EB4.1050306@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39905 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbaBHRXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Feb 2014 12:23:11 -0500
Content-Disposition: inline
In-Reply-To: <52F65EB4.1050306@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 08, 2014 at 08:43:32AM -0800, Ben Greear wrote:
> On 02/03/2014 02:06 PM, Ben Greear wrote:
> > On 02/03/2014 02:03 PM, Hannes Frederic Sowa wrote:
> >> Hi Ben,
> >>
> >> On Mon, Feb 03, 2014 at 12:37:52PM -0800, Ben Greear wrote:
> >>> The kernel has some additional patches, but not much to IPv6.
> >>>
> >>> The bug is that when we have lots of mac-vlans on some ixgbe ports
> >>> (500 per interface in this case), and boot up the system with the ports unplugged,
> >>> we get this crash almost every time.  Boot-up is going to do normal bootup
> >>> stuff plus create and configure the 1000 mac-vlans, dump their routing
> >>> tables, etc.
> >>>
> >>> We are using one routing table per network device, and some
> >>> ip rules.
> >>>
> >>> If we plug in the ixgbe ports, we do not ever see a crash.
> >>>
> >>> We have not yet tried reproducing it on other drivers, but I suspect
> >>> the issue is not related to ixgbe.
> >>>
> >>> Any ideas on this one?
> >>
> >> Could you bring the machine to a panic again with enabling RT6_DEBUG at the
> >> top of ip6_fib.c and send a dump of the trace?
> > 
> > Yes, but it will be a bit until we can create a duplicate machine.
> > We ended up delivering the machine with a note to make sure the
> > interfaces were plugged in (we found the bug hours before shipping
> > the system, of course).
> 
> According to my system test guy, it took a lot longer to reproduce
> the problem with the debug enabled kernel, but I do not see any extra
> debug messages on the serial console logging or in /var/log/messages

Sounds like a race, then, like I thought.

I forgot, those are pr_debugs, I usually enable them with

$ echo file net/ipv6/ip6_fib.c +p > /sys/kernel/debug/dynamic_debug/control

RT6_TRACE is pretty noisy so you should see output immediatley if you do ipv6
traffic. Other way is to specify dyndbg="file net/ipv6/ip6_fib.c +p" on the
kernel command line.

Try before doing to play with that until you can confirm the output showes up
on the console.

Thanks again,

  Hannes
