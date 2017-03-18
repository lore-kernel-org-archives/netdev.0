From: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCH 0/5] Add busy poll support for epoll under
 certain circumstances
Date: Sat, 18 Mar 2017 12:45:23 +0100
Message-ID: <CAHO5Pa0h1QMkd5RjBKw6HqrsqgCucq9fXPSeRpdX0BD_QzNe9Q@mail.gmail.com>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170316183142.15806.38824.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[CC += linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org]

Hello Alexander

Since this is a kernel-user-space API change, please CC linux-api@
(and on future iterations of the patch). The kernel source file
Documentation/SubmitChecklist notes that all Linux kernel patches that
change userspace interfaces should be CCed to
linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, so that the various parties who are
interested in API changes are informed. For further information, see
https://www.kernel.org/doc/man-pages/linux-api-ml.html

Thanks,

Michael



On Thu, Mar 16, 2017 at 7:32 PM, Alexander Duyck
<alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> This patch series is meant to add busy polling support to epoll when all of
> the sockets on a given epoll are either local or are being sourced by the
> same NAPI ID.
>
> In order to support this the first two patches clean up a few issues we
> found with the NAPI ID tracking and infrastructure.
>
> In the third patch we introduce SO_INCOMING_NAPI_ID so that applications
> have a means of trying to sort their incoming sockets to identify which
> requests should be routed where in order to keep the epoll listener aligned
> to a given Rx queue without having to rely on IRQ pinning.
>
> Finally the last two patches refactor the existing busy poll infrastructure
> to make it so that we can call it without necessarily needing a socket, and
> enable the bits needed to support epoll when all of the sockets on the
> epoll either share the same NAPI ID, or simply are reporting no NAPI ID.
>
> ---
>
> Sridhar Samudrala (5):
>       net: Do not record sender_cpu as napi_id in socket receive paths
>       net: Call sk_mark_napi_id() in the ACK receive path
>       net: Introduce SO_INCOMING_NAPI_ID
>       net: Commonize busy polling code to focus on napi_id instead of socket
>       epoll: Add busy poll support to epoll with socket fds.
>
>
>  arch/alpha/include/uapi/asm/socket.h   |    2 +
>  arch/avr32/include/uapi/asm/socket.h   |    2 +
>  arch/frv/include/uapi/asm/socket.h     |    2 +
>  arch/ia64/include/uapi/asm/socket.h    |    2 +
>  arch/m32r/include/uapi/asm/socket.h    |    2 +
>  arch/mips/include/uapi/asm/socket.h    |    2 +
>  arch/mn10300/include/uapi/asm/socket.h |    2 +
>  arch/parisc/include/uapi/asm/socket.h  |    2 +
>  arch/powerpc/include/uapi/asm/socket.h |    2 +
>  arch/s390/include/uapi/asm/socket.h    |    2 +
>  arch/sparc/include/uapi/asm/socket.h   |    2 +
>  arch/xtensa/include/uapi/asm/socket.h  |    2 +
>  fs/eventpoll.c                         |  115 ++++++++++++++++++++++++++++++++
>  include/net/busy_poll.h                |   14 +++-
>  include/uapi/asm-generic/socket.h      |    2 +
>  net/core/dev.c                         |   16 ++--
>  net/core/sock.c                        |   22 ++++++
>  net/ipv4/tcp_ipv4.c                    |    1
>  18 files changed, 183 insertions(+), 11 deletions(-)
>
> --



-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/
