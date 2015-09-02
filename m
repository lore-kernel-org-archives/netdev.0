From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] x86: Wire up 32-bit direct socket calls
Date: Wed, 2 Sep 2015 11:48:05 +0200
Message-ID: <CAMuHMdXKA_+JY2ryf-yoJxQnbW=jsOjj_w2-Nsybpx0310neDA@mail.gmail.com>
References: <cb5138299d37d5800e2d135b01a7667fa6115854.1436912629.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: X86 ML <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Tulio Magno Quites Machado Filho
	<tuliom@linux.vnet.ibm.com>, Andy Lutomirski <luto@amacapital.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexander Larsson <alexl@redhat.com>,
	Cosimo Cecchi <cosimo@endlessm.com>,
	Dan Nicholson <nicholson@endlessm.com>,
	libc-alpha <libc-alpha@sourceware.org>,
	Rajalakshmi Srinivasaraghavan <raji@linux.vnet.ibm.com>,
	Linux-Arch <linux-arch@vger.kernel.org>
To: Andy Lutomirski <luto@kernel.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <cb5138299d37d5800e2d135b01a7667fa6115854.1436912629.git.luto@kernel.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 15, 2015 at 12:24 AM, Andy Lutomirski <luto@kernel.org> wrote:
> On x86_64, there's no socketcall syscall; instead all of the socket
> calls are real syscalls.  For 32-bit programs, we're stuck offering
> the socketcall syscall, but it would be nice to expose the direct
> calls as well.  This will enable seccomp to filter socket calls (for
> new userspace only, but that's fine for some applications) and it
> will provide a tiny performance boost.
>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/entry/syscalls/syscall_32.tbl | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
>
> diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
> index ef8187f9d28d..25e3cf1cd8fd 100644
> --- a/arch/x86/entry/syscalls/syscall_32.tbl
> +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> @@ -365,3 +365,18 @@
>  356    i386    memfd_create            sys_memfd_create
>  357    i386    bpf                     sys_bpf
>  358    i386    execveat                sys_execveat                    stub32_execveat
> +359    i386    socket                  sys_socket
> +360    i386    socketpair              sys_socketpair
> +361    i386    bind                    sys_bind
> +362    i386    connect                 sys_connect
> +363    i386    listen                  sys_listen
> +364    i386    accept4                 sys_accept4
> +365    i386    getsockopt              sys_getsockopt                  compat_sys_getsockopt
> +366    i386    setsockopt              sys_setsockopt                  compat_sys_setsockopt
> +367    i386    getsockname             sys_getsockname
> +368    i386    getpeername             sys_getpeername
> +369    i386    sendto                  sys_sendto
> +370    i386    sendmsg                 sys_sendmsg                     compat_sys_sendmsg
> +371    i386    recvfrom                sys_recvfrom                    compat_sys_recvfrom
> +372    i386    recvmsg                 sys_recvmsg                     compat_sys_recvmsg
> +373    i386    shutdown                sys_shutdown

Should all other architectures follow suit?
Or should we follow the s390 approach:

commit 5a7ff75a0c63222d138d944240146dc49a9624e1
Author: Heiko Carstens <heiko.carstens@de.ibm.com>
Date:   Tue Aug 4 09:15:58 2015 +0200

    s390/syscalls: ignore syscalls reachable via sys_socketcall

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
