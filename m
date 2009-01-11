From: bert hubert <bert.hubert@netherlabs.nl>
Subject: SO_LINGER dead: I get an immediate RST on 2.6.24?
Date: Sun, 11 Jan 2009 22:23:03 +0100
Message-ID: <20090111212303.GA8612@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([85.17.220.215]:40006 "EHLO outpost.ds9a.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753299AbZAKVtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 16:49:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everybody,

I have an application where I need to send data from A to B, and beforehand,
I don't know how much data this will be. 

B is 'stupid', and consists solely of a TCP/IP port accepting data, and I
have no way to chunk this data. So what I do is issue blocking calls to
write(), shutdown(fd, SHUT_WR), and wait for the fd to become readable which
tells me that the remote has packed up, and I'm good to go.

Before this, I've tried SO_LINGER with various timeouts but nothing helped.

When I tcpdump, I find that my close() is immediately turned into an RST
packet.

Is SO_LINGER a NOOP? Does it still do anything?

I'm about to blog this up - the 'shutdown() and read()' technique is
something I had to purloin from the Apache source.

So I'd love to know the words of the wise on this one.

Thanks.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
