From: Pascal GREGIS <pgs@synerway.com>
Subject: Connection reset by peer - need a patch
Date: Fri, 27 Feb 2009 16:07:55 +0100
Message-ID: <20090227150755.GE2796@venus.synerway.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.synerway.com ([84.14.10.249]:41505 "EHLO
	kamino.synerway.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753000AbZB0PXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 10:23:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi people,

I have a very annoying bug that seems to be well known today.
It happens on a backup server that issue a "Connection reset by peer" while the other side does not reset or stop the connection.

I have found a report that seems very similar on this mailing list :
http://kerneltrap.org/index.php?q=mailarchive/linux-netdev/2008/4/28/1628834

this sends to the commit 7951f0b03a63d657c72c7d54d306ef3357e7e604
Author: Daniel Lezcano <...
Date: Thu Apr 10 20:53:10 2008 -0700
    [NETNS][IPV6] tcp - assign the netns for timewait sockets

and gives a simple patch that adds the line 
    tw->tw_net = sk->sk_net;
somewhere in the function inet_twsk_alloc (in the file net/ipv4/inet_timewait_sock.c).

Right, but the problem is that I use a kernel 2.6.21.1 and cannot upgrade my whole kernel easily.
And in the kernel 2.6.21.1, network namespaces don't seem to exist, so I cannot apply this simple patch.

I am in a very uncomfortable situation because this bug is causing harmfull problems on all the backup servers of my company and as I said above, upgrading the kernel is not really possible at this time.

Does anyone know what I could do to solve this ?

Thanks a lot

Pascal

