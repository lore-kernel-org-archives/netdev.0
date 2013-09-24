From: David Madore <david+ml@madore.org>
Subject: IP_FREEBIND with IPv6
Date: Tue, 24 Sep 2013 11:24:57 +0200
Message-ID: <20130924092457.GA6781@achernar.madore.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-netdev mailing-list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from achernar.gro-tsen.net ([88.191.144.68]:36850 "EHLO
	achernar.gro-tsen.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754395Ab3IXJdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 05:33:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear list,

I have two questions regarding the IP_FREEBIND option in IPv6.

Consider the following script, which sets IP_FREEBIND and then tries
to bind to some arbitrary non-local IPv6 address:

### cut after ###
#! /usr/bin/env python
import socket
if not hasattr(socket, 'IP_FREEBIND'):
    socket.IP_FREEBIND = 15
s = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.setsockopt(socket.SOL_IP, socket.IP_FREEBIND, 1)
s.bind(("fd42:dead:beef::1", 0))
print "success"
### cut before ###

* This fails (with EADDRNOTAVAIL) under the long-term 3.2 kernels (I
  tried with 3.2.50 and also the current Debian stable kernel,
  3.2.0-4-amd64).  On the other hand, it succeeds with a more recent
  kernel (I tried 3.10.10).  Is this to be considered a bug in the 3.2
  kernel?  I attempted to find which commit fixed this behavior,
  without success: can someone point out to the appropriate patch?
  Could this conceivably be proposed for inclusion in 3.2?

* If one sets net.ipv4.ip_nonlocal_bind to 1 then (according to ip(7))
  the script should work even without the s.setsockopt(socket.SOL_IP,
  socket.IP_FREEBIND, 1) line.  I have failed to make this work on any
  version of the kernel.  Again, is this a bug or a misunderstanding
  on my part of what net.ipv4.ip_nonlocal_bind should do?  (I am aware
  it says "ipv4" in the sysctl name, but since there is no
  corresponding net.ipv6.ip_nonlocal_bind, I don't see what else one
  is supposed to use.)

Best regards,

-- 
     David A. Madore
   ( http://www.madore.org/~david/ )
