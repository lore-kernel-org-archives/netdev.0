From: Chris Friesen <chris.friesen@genband.com>
Subject: how to listen() on single IP address but very many ports?
Date: Fri, 18 Feb 2011 11:55:58 -0600
Message-ID: <4D5EB2AE.5050703@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og118.obsmtp.com ([64.18.2.8]:33195 "EHLO
	exprod7og118.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596Ab1BRR4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 12:56:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I have an application team that needs to listen() for tcp connections on
many ports (and by many I mean pretty much all 64K ports).  However, the
connections are short-lived, and the number of active connections at any
given time is small.

Apparently when they tried this before on an older kernel the
performance of the naive "open 60K sockets and call listen()" solution
was not acceptable, so they used NAT with port mapping to direct all the
incoming packets to a single real port.  However, they now want to add
support for IPv6 and this solution won't work.

What's the recommended method for efficiently listening on this many
ports?  Should I be able to efficiently listen() on that many sockets
using epoll or similar?  If there isn't a way to do this, is there an
equivalent IPv6 workaround?

One possible solution that came up was to implement a PORT_ANY which
would match any incoming request that didn't already have an explicit
listener.  Even better would be a way to bind a single listening socket
to a range of ports.

Has anyone ever considered something like this?

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
