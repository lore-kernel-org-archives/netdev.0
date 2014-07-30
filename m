From: fche-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org (Frank Ch. Eigler)
Subject: Re: [PATCH RFC v3 net-next 3/3] samples: bpf: eBPF dropmon example in C
Date: Wed, 30 Jul 2014 11:45:28 -0400
Message-ID: <y0m1tt226lj.fsf@fche.csb>
References: <1406000723-4872-1-git-send-email-ast@plumgrid.com>
	<1406000723-4872-4-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
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
In-Reply-To: <1406000723-4872-4-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> (Alexei Starovoitov's message of "Mon, 21 Jul 2014 20:45:23 -0700")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


ast wrote earlier:

> [...]
> dtrace/systemtap/ktap approach is to use one script file that should provide
> all desired functionality. That architectural decision overcomplicated their
> implementations.
>
> eBPF follows split model: everything that needs to process millions of events
> per second needs to run in kernel and needs to be short and deterministic,
> all other things like aggregation and nice graphs should run in user space.
> [...]

For the record, this is not entirely accurate as to dtrace.  dtrace
delegates aggregation and most reporting to userspace.  Also,
systemtap is "short and deterministic" even for aggregations & nice
graphs, but since it limits its storage & cpu consumption, its
arrays/reports cannot get super large.


> [...]
> +SEC("events/skb/kfree_skb")
> +int bpf_prog2(struct bpf_context *ctx)
> +{
> +[...]
> +	value = bpf_map_lookup_elem(&my_map, &loc);
> +	if (value)
> +		(*(long *) value) += 1;
> +	else
> +		bpf_map_update_elem(&my_map, &loc, &init_val);
> +	return 0;
> +}

What kind of locking/serialization is provided by the ebpf runtime
over shared variables such as my_map?


- FChE
