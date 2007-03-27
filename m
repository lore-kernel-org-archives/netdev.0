From: Agoston Horvath <agoston@ripe.net>
Subject: IPv6: Connection reset/timeout under heavy load
Date: Tue, 27 Mar 2007 13:02:41 +0200
Message-ID: <4608F9D1.4060109@ripe.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070705040608020708090807"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postman.ripe.net ([193.0.0.199]:58349 "EHLO postman.ripe.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753816AbXC0L24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 07:28:56 -0400
Received: from herring.ripe.net (herring.ripe.net [193.0.1.203])
	by postman.ripe.net (Postfix) with ESMTP id 26F2923F4C
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 13:02:42 +0200 (CEST)
Received: from [193.0.1.50] (x50.ripe.net [193.0.1.50])
	by herring.ripe.net (Postfix) with ESMTP id 191902F598
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 13:02:42 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070705040608020708090807
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hello,

I'm trying to add ipv6 support to the RIPE whois-server. I'm going with the dual-stack address familiy independent solution (/proc/sys/net/ipv6/bindv6only is set to 0).
I've written a small piece of code which tests how the server behaves under heavy load. It basically creates a specified number of threads and hammers the query port of the server with logged real-world queries. This works fine over ipv4. But if I switch to ipv6 (meaning, instead of the ipv4 address of eth0, I give the ipv6 one to getaddrinfo()), strange connection reset/timeout problems arise. This is especially strange because it's all AF-independent, so the very same piece of code runs fine for ipv4, but fails for ipv6.

I've created a small excerpt of the connection code (see attachment), which can be used to reproduce the problem. I've played around with number of clients/servers and the number of threads, and came to the conclusion that the problem is most probably in either in libc or in the kernel.
Strangest thing is that if I set the client to use 1 thread only, it works well. If I either start 2 pieces of 1-threaded clients or 1 piece of 2-threaded client, they start throwing errors.

I've even fiddled with sysctls tcp_fin_timeout, tcp_tw_recycle and tcp_tw_reuse, but it didn't change anything. Setting SO_LINGER to a smaller value also didn't help.

I'm using kernel 2.6.16.29, libc is 2.3.2.ds1-22sarge5. However, same result was achieved using kernel version 2.6.13 on the same box.

I'm out of further ideas. If anyone can give me some pointers about what could be wrong, please, don't spare me.

Thanks,
Agoston


--------------070705040608020708090807
Content-Type: application/x-gzip;
 name="load_test.tar.gz"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="load_test.tar.gz"

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
v4oAUAAA
--------------070705040608020708090807--
