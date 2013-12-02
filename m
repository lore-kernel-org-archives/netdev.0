From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH openvswitch v2] netlink: Implement & enable memory mapped
 netlink i/o
Date: Mon, 2 Dec 2013 13:23:25 -0800
Message-ID: <20131202212325.GG15335@nicira.com>
References: <6a9efcafd9386ddd24fbfabb799bd2b5cc536430.1385814132.git.tgraf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org,
	dborkman@redhat.com, ffusco@redhat.com, fleitner@redhat.com,
	xiyou.wangcong@gmail.com
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:57983 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758047Ab3LBVXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 16:23:31 -0500
Received: by mail-qa0-f50.google.com with SMTP id i13so5006676qae.9
        for <netdev@vger.kernel.org>; Mon, 02 Dec 2013 13:23:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <6a9efcafd9386ddd24fbfabb799bd2b5cc536430.1385814132.git.tgraf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 30, 2013 at 01:27:33PM +0100, Thomas Graf wrote:
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
> Signed-off-by: Thomas Graf <tgraf@redhat.com>

Clang reports:

    ../lib/netlink-socket.c:330:12: error: cast from 'char *' to 'struct nl_mmap_hdr *' increases required alignment from 1 to 4 [-Werror,-Wcast-align]
        return (struct nl_mmap_hdr *)(start + r->head * sock->frame_size);
               ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ../lib/netlink-socket.c:369:22: error: implicit declaration of function '__ALIGN_KERNEL' is invalid in C99 [-Werror,-Wimplicit-function-declaration]
    -> sock->frame_size)
                         ^
    ../lib/netlink-protocol.h:213:26: note: expanded from macro 'NL_MMAP_HDRLEN'
    #define NL_MMAP_HDRLEN                  NL_MMAP_MSG_ALIGN(sizeof(struct nl_mmap_hdr))
                                            ^
    ../lib/netlink-protocol.h:212:32: note: expanded from macro 'NL_MMAP_MSG_ALIGN'
    #define NL_MMAP_MSG_ALIGN(sz)           __ALIGN_KERNEL(sz, NL_MMAP_MSG_ALIGNMENT)
                                            ^
GCC reports:

    ../lib/netlink-socket.c: In function 'nl_sock_send_mmap':
    ../lib/netlink-socket.c:369:5: error: implicit declaration of function '__ALIGN_KERNEL' [-Werror=implicit-function-declaration]
    cc1: all warnings being treated as errors

Thanks,

Ben.
