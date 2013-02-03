From: David Madore <david+ml@madore.org>
Subject: Re: assigning an entire subnet of addresses to an interface
Date: Sun, 3 Feb 2013 23:35:49 +0100
Message-ID: <20130203223549.GA14927@achernar.madore.org>
References: <20130203205124.GA13738@aldebaran.madore.org>
 <DUB107-W70CD0C5839AA44142F48CED020@phx.gbl>
 <20130203220057.GA14363@achernar.madore.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lukas Tribus <luky-37@hotmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from achernar.gro-tsen.net ([88.191.144.68]:41905 "EHLO
	achernar.gro-tsen.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834Ab3BCWfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 17:35:51 -0500
Content-Disposition: inline
In-Reply-To: <20130203220057.GA14363@achernar.madore.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 03, 2013 at 11:00:57PM +0100, David Madore wrote:
> This is indeed, interesting, and I'm glad you pointed out this
> possibility, because it had escaped my radar.  (Note that there are
> two slightly different things, though: the TPROXY iptables/ip6tables
> target which redirects packets to a local socket, and the IP-level
> IP_TRANSPARENT socket option which allows a user application to bind
> to an arbitrary address.  The latter is closer to what I was asking.)

Another related and interesting IP-level socket option is IP_FREEBIND.
I suppose the different between IP_FREEBIND and IP_TRANSPARENT is that
the former does not cause any routing changes, but the net effect is
that, after the "ip -6 route add local 2001:db8:f00f::/48 dev lo"
command that I had contemplated, binding with IP_FREEBIND does allow
the socket to obtain packets destined to an arbitrary address inside
the subnet.  Without requiring administrator privileges (of course,
they are required to run the ip route command).

But I'd still be happier if there were some way that required
absolutely no modification on the userland side after a few
administrative commands to make the prefix available.

-- 
     David A. Madore
   ( http://www.madore.org/~david/ )
