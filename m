From: Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC net-next 01/14] net: filter: split filter.c into two files
Date: Wed, 02 Jul 2014 13:23:34 +0900
Message-ID: <8738ek5qyh.fsf@sejong.aot.lge.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1403913966-4927-2-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> (Alexei
	Starovoitov's message of "Fri, 27 Jun 2014 17:05:53 -0700")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alexei,

On Fri, 27 Jun 2014 17:05:53 -0700, Alexei Starovoitov wrote:
> BPF is used in several kernel components. This split creates logical boundary
> between generic eBPF core and the rest
>
> kernel/bpf/core.c: eBPF interpreter
>
> net/core/filter.c: classic->eBPF converter, classic verifiers, socket filters
>
> This patch only moves functions.
>
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
> ---
>  kernel/Makefile     |    1 +
>  kernel/bpf/Makefile |    1 +
>  kernel/bpf/core.c   |  545 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  net/core/filter.c   |  520 ------------------------------------------------
>  4 files changed, 547 insertions(+), 520 deletions(-)
>  create mode 100644 kernel/bpf/Makefile
>  create mode 100644 kernel/bpf/core.c
>
> diff --git a/kernel/Makefile b/kernel/Makefile
> index f2a8b6246ce9..e7360b7c2c0e 100644
> --- a/kernel/Makefile
> +++ b/kernel/Makefile
> @@ -87,6 +87,7 @@ obj-$(CONFIG_RING_BUFFER) += trace/
>  obj-$(CONFIG_TRACEPOINTS) += trace/
>  obj-$(CONFIG_IRQ_WORK) += irq_work.o
>  obj-$(CONFIG_CPU_PM) += cpu_pm.o
> +obj-$(CONFIG_NET) += bpf/

But this still requires CONFIG_NET to use bpf.  Why not adding
CONFIG_BPF and making CONFIG_NET selects it?

Thanks,
Namhyung
