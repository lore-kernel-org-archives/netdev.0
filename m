From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridge stays down until a port is added
Date: Sat, 20 Aug 2011 09:30:59 -0700
Message-ID: <20110820093059.75c37a1f@nehalam.ftrdhcpuser.net>
References: <20110811070659.GA21307@torres.zugschlus.de>
	<20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
	<20110811205429.GB21307@torres.zugschlus.de>
	<alpine.DEB.2.02.1108121418090.11637@aurora>
	<20110820094712.GC21307@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sven-Haegar Koch <haegar@sdinet.de>
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60196 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753198Ab1HTQay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Aug 2011 12:30:54 -0400
In-Reply-To: <20110820094712.GC21307@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Aug 2011 11:47:12 +0200
Marc Haber <mh+netdev@zugschlus.de> wrote:

> Hi,
> 
> I was a little bit confused. The problem is that with IPv6 an IP
> address configured on a bridge which is still in the NO-CARRIER state
> will never leave tentative state and will thus not get useable.
> 
> On Fri, Aug 12, 2011 at 02:22:27PM +0200, Sven-Haegar Koch wrote:
> > For me (using kernel 3.0.0) it seems to work as I expect it:
> > 
> > aurora:~# brctl addbr br0
> > aurora:~# ifconfig br0 192.168.254.1 netmask 255.255.255.0 up
> > aurora:~# ping 192.168.254.1
> > PING 192.168.254.1 (192.168.254.1) 56(84) bytes of data.
> > 64 bytes from 192.168.254.1: icmp_req=1 ttl=64 time=0.087 ms
> 
> Now try it with IPv6.
> 

The problem is that IPv6 Duplicate Address Detection needs to
work. This is not a simple problem.  If the bridge asserted
carrier with no ports then:

1. IPv6 address assigned and IPv6 decides it is okay.
2. Port added later
3. Another system has the same address.
*broke*

If you want to avoid DAD, then you can configure disable DAD
by setting /proc/sys/net/ipv6/conf/br0/accept_dad to 0
