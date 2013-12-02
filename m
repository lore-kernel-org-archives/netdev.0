From: Thomas Graf <tgraf@redhat.com>
Subject: Re: [PATCH openvswitch v2] netlink: Implement & enable memory mapped
 netlink i/o
Date: Mon, 02 Dec 2013 23:16:31 +0100
Message-ID: <529D06BF.1010701@redhat.com>
References: <6a9efcafd9386ddd24fbfabb799bd2b5cc536430.1385814132.git.tgraf@redhat.com> <20131202212325.GG15335@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org,
	dborkman@redhat.com, ffusco@redhat.com, fleitner@redhat.com,
	xiyou.wangcong@gmail.com
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26275 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753033Ab3LBWRC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Dec 2013 17:17:02 -0500
In-Reply-To: <20131202212325.GG15335@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/2013 10:23 PM, Ben Pfaff wrote:
> On Sat, Nov 30, 2013 at 01:27:33PM +0100, Thomas Graf wrote:
>> Based on the initial patch by Cong Wang posted a couple of months
>> ago.
>>
>> This is the user space counterpart needed for the kernel patch
>> '[PATCH net-next 3/8] openvswitch: Enable memory mapped Netlink i/o'
>>
>> Allows the kernel to construct Netlink messages on memory mapped
>> buffers and thus avoids copying. The functionality is enabled on
>> sockets used for unicast traffic.
>>
>> Further optimizations are possible by avoiding the copy into the
>> ofpbuf after reading.
>>
>> Signed-off-by: Thomas Graf <tgraf@redhat.com>
>
> Clang reports:
>
>      ../lib/netlink-socket.c:330:12: error: cast from 'char *' to 'struct nl_mmap_hdr *' increases required alignment from 1 to 4 [-Werror,-Wcast-align]
>          return (struct nl_mmap_hdr *)(start + r->head * sock->frame_size);
>                 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>      ../lib/netlink-socket.c:369:22: error: implicit declaration of function '__ALIGN_KERNEL' is invalid in C99 [-Werror,-Wimplicit-function-declaration]
>      -> sock->frame_size)
>                           ^
>      ../lib/netlink-protocol.h:213:26: note: expanded from macro 'NL_MMAP_HDRLEN'
>      #define NL_MMAP_HDRLEN                  NL_MMAP_MSG_ALIGN(sizeof(struct nl_mmap_hdr))
>                                              ^
>      ../lib/netlink-protocol.h:212:32: note: expanded from macro 'NL_MMAP_MSG_ALIGN'
>      #define NL_MMAP_MSG_ALIGN(sz)           __ALIGN_KERNEL(sz, NL_MMAP_MSG_ALIGNMENT)
>                                              ^
> GCC reports:
>
>      ../lib/netlink-socket.c: In function 'nl_sock_send_mmap':
>      ../lib/netlink-socket.c:369:5: error: implicit declaration of function '__ALIGN_KERNEL' [-Werror=implicit-function-declaration]
>      cc1: all warnings being treated as errors

Just so we can simplify this process: what's the oldest environment you
want the code to compile on?
