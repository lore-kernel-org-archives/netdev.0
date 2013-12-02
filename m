From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH openvswitch v2] netlink: Implement & enable memory mapped
 netlink i/o
Date: Mon, 2 Dec 2013 14:26:30 -0800
Message-ID: <20131202222630.GJ15335@nicira.com>
References: <6a9efcafd9386ddd24fbfabb799bd2b5cc536430.1385814132.git.tgraf@redhat.com>
 <20131202212325.GG15335@nicira.com>
 <529D06BF.1010701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org,
	dborkman@redhat.com, ffusco@redhat.com, fleitner@redhat.com,
	xiyou.wangcong@gmail.com
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:33070 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754245Ab3LBW0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 17:26:39 -0500
Received: by mail-qa0-f41.google.com with SMTP id j5so4968756qaq.7
        for <netdev@vger.kernel.org>; Mon, 02 Dec 2013 14:26:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <529D06BF.1010701@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 02, 2013 at 11:16:31PM +0100, Thomas Graf wrote:
> >GCC reports:
> >
> >     ../lib/netlink-socket.c: In function 'nl_sock_send_mmap':
> >     ../lib/netlink-socket.c:369:5: error: implicit declaration of function '__ALIGN_KERNEL' [-Werror=implicit-function-declaration]
> >     cc1: all warnings being treated as errors
> 
> Just so we can simplify this process: what's the oldest environment you
> want the code to compile on?

FreeBSD.

This is not a Linux-specific header, it is included on all platforms.
As the comment at the top says:

/* Netlink protocol definitions.
 *
 * Netlink is a message framing format described in RFC 3549 and used heavily
 * in Linux to access the network stack.  Open vSwitch uses AF_NETLINK sockets
 * for this purpose on Linux.  But on all platforms, Open vSwitch uses Netlink
 * message framing internally for certain purposes.
 *
 * This header provides access to the Netlink message framing definitions
 * regardless of platform.  On Linux, it includes the proper headers directly;
 * on other platforms it directly defines the structures and macros itself.
 */
