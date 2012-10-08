From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 0/3] ipv4: pmtu fixes
Date: Mon, 8 Oct 2012 10:46:42 +0200
Message-ID: <20121008084642.GB15622@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46754 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753794Ab2JHIqu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 04:46:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes some issues that came with the routing cache removal.

1) IPsec and others (udp, ipvs) may cache output routes, these routes
need to be invalidated on pmtu events in the same way e.g. tcp socket
cached routes are invalidated. With this we always invalidate or update
(if we already use a nh exeption route) the old route on pmtu events. 

This has the drawback that we may needlessly invalidate an uncached route,
but this fixes all the users that cache routes and pmtu events are rare, so
this should not be a real issue.

2) We create nh exeptions if a user (e.g. tracepath) tries to do pmtu
dicsovery with packets bigger than the output device mtu. The device mtu
is not learned and does not expire, so don't create an exeption route.

3) We report cached pmtu values to userspace even if they are expired.
Fix this by checking for expiration before we report.
