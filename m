From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: ipv6: why disable ipv6 on last address removal?
Date: Wed, 9 Dec 2009 08:18:17 +0100
Message-ID: <20091209071817.GA4554@smudla.bakulak.kosire.czf>
References: <20091208192046.GA5649@midget.suse.cz>
 <20091208.125611.135547597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbohac@suse.cz, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:38867 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757048AbZLIHSN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2009 02:18:13 -0500
Content-Disposition: inline
In-Reply-To: <20091208.125611.135547597.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2009 at 12:56:11PM -0800, David Miller wrote:
> From: Jiri Bohac <jbohac@suse.cz>
> > Is there any reason why inet6_addr_del needs to sets how=1 and
> > disable IPv6 even more than "ifconfig down" does?
> 
> All I can say is that this behavior is definitely on purpose, although
> I don't exactly remember why.

> Some people definitely expect no IPV6 at all in any way shape or
> form if they have not assigned IPV6 addresses to an interface.

Sure, even with how=0, IPv6 is about as much disabled as when the
interface is down. The problem is that the current behaviour goes
like this:

#1 modprobe driver_for_eth0
#2 sysctl net.ipv6.conf.tun0.aaaaaaa=b
#3 ip link set up dev eth0
#4 ip addr add xxx/yy dev eth0
#5 ip addr flush dev eth0
#6 ip link set down dev eth0 
#7 ip link set up dev eth0

#5 turns IPv6 off even deeper that it was after #1, losing the
settings made in #2.

To re-configure the settings from #2, you need to do:
#6, #7, [#6 again for some sysctl settings], #2

I think it would probably be ok for #5 to turn off IPv6 to the
state you get with #6.

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

