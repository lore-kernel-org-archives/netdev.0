From: Alex Bligh <alex@alex.org.uk>
Subject: Listing ipv6 proxy neighbours
Date: Wed, 07 Nov 2012 09:03:54 +0000
Message-ID: <CC966090B4F10E8F4612D351@nimrod.local>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Bligh <alex@alex.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:51202 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996Ab2KGJN0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2012 04:13:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If I set up an ipv6 proxy neighbour like this:
 echo 1 > /proc/sys/net/ipv6/conf/eth0/proxy_ndp
 ip neigh add proxy 2a01:2345:8b25:7ea0::22 dev eth0
it appears to go into the kernel OK (the first delete works, the second does not).

However, there appears to be no way of listing them in that
 ip -6 neigh show
does not list them.

I assumed this was a bug in 'ip', which I set about trying to fix. Modern 'ip'
has a new command 'ip -6 neigh show proxy' but this also does not list them.
As far as I can tell, stepping through 'ip' with gdb, and commenting out
some of the more obvious if conditions filtering out returns from the kernel,
the kernel is not actually listing these through netlink.

ip maddr show shows a multicast group created, so it's in there somewhere.

$ ./ip -6 maddr show
1:	lo
	inet6 ff02::1
2:	eth0
	inet6 ff02::1:ff00:22 <-------- this one
	inet6 ff02::fb
	inet6 ff02::1:ff48:aad6
	inet6 ff02::1

Any ideas?

-- 
Alex Bligh
