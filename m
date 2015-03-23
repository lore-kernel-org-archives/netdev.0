From: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v9 tip 6/9] samples: bpf: simple non-portable kprobe
 filter example
Date: Mon, 23 Mar 2015 08:29:29 +0100
Message-ID: <20150323072929.GB25184@gmail.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com>
 <1426894210-27441-7-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1426894210-27441-7-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


* Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:

> tracex1_kern.c - C program compiled into BPF.
> It attaches to kprobe:netif_receive_skb
> When skb->dev->name == "lo", it prints sample debug message into trace_pipe
> via bpf_trace_printk() helper function.
> 
> tracex1_user.c - corresponding user space component that:
> - loads bpf program via bpf() syscall
> - opens kprobes:netif_receive_skb event via perf_event_open() syscall
> - attaches the program to event via ioctl(event_fd, PERF_EVENT_IOC_SET_BPF, prog_fd);
> - prints from trace_pipe
> 
> Note, this bpf program is completely non-portable. It must be recompiled
> with current kernel headers. kprobe is not a stable ABI and bpf+kprobe scripts
> may stop working any time.
> 
> bpf verifier will detect that it's using bpf_trace_printk() and kernel will
> print warning banner:
> ** trace_printk() being used. Allocating extra memory.  **

Printing this might be OK.

> **                                                      **
> ** This means that this is a DEBUG kernel and it is     **
> ** unsafe for production use.                           **

But I think printing that it's unsafe for production use is over the 
top: it's up to the admin whether it's safe or unsafe, just like 
inserting a kprobe can be safe or unsafe.

Informing that something happened is enough.

Thanks,

	Ingo
