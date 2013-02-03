From: David Madore <david+ml@madore.org>
Subject: assigning an entire subnet of addresses to an interface
Date: Sun, 3 Feb 2013 21:51:24 +0100
Message-ID: <20130203205124.GA13738@aldebaran.madore.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux Netdev Mailing-List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from achernar.gro-tsen.net ([88.191.144.68]:41898 "EHLO
	achernar.gro-tsen.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753589Ab3BCVAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 16:00:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear list,

Is there a way to assign an entire subnet of (typically IPv6)
addresses to an interface?  For example, I'd like to assign the entire
2001:db8:f00f::/48 prefix to eth42 without actually running 2^80
separate "ip addr add" commands.

I'm aware that (with sufficiently recent kernels) one can do this:

ip -6 route add local 2001:db8:f00f::/48 dev lo

- which will cause packets received for any address in this subnet to
be handled locally.  But that doesn't really answer my question,
because this does not allow local processes to bind to any desired
address in the subnet (e.g., running "socat
'TCP6-LISTEN:9876,bind=3D[2001:db8:f00f::3141:5926]'" fails with
EADDRNOTAVAIL).

Now apparently Linux _does_ have features which allow a process to
bind to any desired address in a subnet, since this is the case for
the IPv4 127.0.0.0/8 standard loopback (I can run "socat
'TCP-LISTEN:9876,bind=3D[127.1.2.3]' -" without error).  In a na=EFve
move, I tried to reproduce the output of ip addr show for the
127.0.0.0/8 subnet as input, but failed (there's an extra word "lo" in
the output that ip does not allow back as input).  Is this because
this subnet is really magical to the kernel, or because ip input
parsing is incomplete, or for some other reason?

If the feature is not presently available in Linux, is there some hope
that it eventually will be?  How hard would it be to add it?

Thanks in advance,

--=20
     David A. Madore
   ( http://www.madore.org/~david/ )
