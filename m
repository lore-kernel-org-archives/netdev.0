From: Ben Pfaff <blp@nicira.com>
Subject: Re: [ovs-dev] [PATCH openvswitch] netlink: Implement & enable memory
 mapped netlink i/o
Date: Mon, 25 Nov 2013 15:02:53 -0800
Message-ID: <20131125230253.GR1435@nicira.com>
References: <2336aeee25d64eab89302c28c33b7cb7d1a55560.1385057738.git.tgraf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse@nicira.com, dev@openvswitch.org, fleitner@redhat.com,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:34454 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751258Ab3KYXDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 18:03:01 -0500
Received: by mail-qa0-f41.google.com with SMTP id j5so3671767qaq.7
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 15:03:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <2336aeee25d64eab89302c28c33b7cb7d1a55560.1385057738.git.tgraf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 21, 2013 at 07:16:54PM +0100, Thomas Graf wrote:
> Based on the initial patch by Cong Wang posted a couple of months
> ago.
> 
> This is the user space counterpart needed for the kernel patch
> '[PATCH net-next 3/8] openvswitch: Enable memory mapped Netlink i/o'
> 
> Allows the kernel to construct Netlink messages on memory mapped
> buffers and thus avoids copying. The functionality is enabled on
> sockets used for unicast traffic.
> 
> Further optimizations are possible by avoiding the copy into the
> ofpbuf after reading.
> 
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Thomas Graf <tgraf@redhat.com>

Does this depend on other patches or some specific Linux kernel
headers?  It doesn't build here on GCC (similar results with Clang):

../lib/netlink-socket.c: In function 'nl_sock_set_ring':
../lib/netlink-socket.c:101:12: error: variable 'req' has initializer but incomplete type
../lib/netlink-socket.c:102:9: error: unknown field 'nm_block_size' specified in initializer
../lib/netlink-socket.c:102:9: error: excess elements in struct initializer [-Werror]
../lib/netlink-socket.c:102:9: error: (near initialization for 'req') [-Werror]
../lib/netlink-socket.c:103:9: error: unknown field 'nm_block_nr' specified in initializer
../lib/netlink-socket.c:103:9: error: excess elements in struct initializer [-Werror]
../lib/netlink-socket.c:103:9: error: (near initialization for 'req') [-Werror]
../lib/netlink-socket.c:104:9: error: unknown field 'nm_frame_size' specified in initializer
../lib/netlink-socket.c:104:9: error: excess elements in struct initializer [-Werror]
../lib/netlink-socket.c:104:9: error: (near initialization for 'req') [-Werror]
../lib/netlink-socket.c:101:24: error: storage size of 'req' isn't known
../lib/netlink-socket.c:109:43: error: 'NETLINK_RX_RING' undeclared (first use in this function)
../lib/netlink-socket.c:109:43: note: each undeclared identifier is reported only once for each function it appears in
../lib/netlink-socket.c:110:46: error: 'NETLINK_TX_RING' undeclared (first use in this function)
../lib/netlink-socket.c:101:24: error: unused variable 'req' [-Werror=unused-variable]
../lib/netlink-socket.c: In function 'nl_sock_send_mmap':
../lib/netlink-socket.c:369:22: error: 'NL_MMAP_HDRLEN' undeclared (first use in this function)
../lib/netlink-socket.c:374:12: error: dereferencing pointer to incomplete type
../lib/netlink-socket.c:374:27: error: 'NL_MMAP_STATUS_UNUSED' undeclared (first use in this function)
../lib/netlink-socket.c:385:8: error: dereferencing pointer to incomplete type
../lib/netlink-socket.c:386:8: error: dereferencing pointer to incomplete type
../lib/netlink-socket.c:386:23: error: 'NL_MMAP_STATUS_VALID' undeclared (first use in this function)
../lib/netlink-socket.c: In function 'nl_sock_recv_mmap':
../lib/netlink-socket.c:514:16: error: dereferencing pointer to incomplete type
../lib/netlink-socket.c:515:10: error: 'NL_MMAP_STATUS_VALID' undeclared (first use in this function)
../lib/netlink-socket.c:516:16: error: dereferencing pointer to incomplete type
../lib/netlink-socket.c:518:16: error: dereferencing pointer to incomplete type
../lib/netlink-socket.c:518:30: error: 'NL_MMAP_STATUS_UNUSED' undeclared (first use in this function)
../lib/netlink-socket.c:523:40: error: 'NL_MMAP_HDRLEN' undeclared (first use in this function)
../lib/netlink-socket.c:523:59: error: dereferencing pointer to incomplete type
../lib/netlink-socket.c:527:10: error: 'NL_MMAP_STATUS_COPY' undeclared (first use in this function)
../lib/netlink-socket.c:535:10: error: 'NL_MMAP_STATUS_RESERVED' undeclared (first use in this function)
../lib/netlink-socket.c:546:8: error: dereferencing pointer to incomplete type
cc1: all warnings being treated as errors
