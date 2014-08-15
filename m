From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH RFC v4 net-next 17/26] tracing: allow eBPF programs to be
 attached to events
Date: Fri, 15 Aug 2014 12:18:53 -0700
Message-ID: <CALCETrUqop+UB-BhyX4Y41kELO+6kcFdS1F7ZyN0CzRwg4UGhA@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
 <1407916658-8731-18-git-send-email-ast@plumgrid.com> <CAE40pdf0pNYyazjpdkzxNJi7iC4LOOr_XEu078OUqP_uoCXnHg@mail.gmail.com>
 <CAMEtUuymPDhYBe42i4DJNXsdgZRaq9LuEU_nGSsqrY1FcFHqhQ@mail.gmail.com>
 <CALCETrVH8KXr8uSHAVy5eBsqmi1LjB5QZpboAGcjYswXvW1opA@mail.gmail.com>
 <CAMEtUuzey7PanznrAguOpvPLxyhgJB++ovE8RNys7srs=EY1qg@mail.gmail.com>
 <CALCETrVhjO5c7ob1vntx031c5RmxRHimkRt1F2EsmzdKB53_NA@mail.gmail.com>
 <CAMEtUuzT53jeH-L+saW-RopSR2EERO5UKVHyeORTGHVMCHbYag@mail.gmail.com>
 <CALCETrUNvg88_VrwE+9RKnSgts=3zVcXbX6tuNLgUxJU436CrQ@mail.gmail.com> <CAMEtUuwF2_+qzkaW6rkw9cyYJ2eb01B_ZyBcwrJ7nd+GqN5-mQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuwF2_+qzkaW6rkw9cyYJ2eb01B_ZyBcwrJ7nd+GqN5-mQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 15, 2014 at 12:16 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> On Fri, Aug 15, 2014 at 12:02 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>>
>>> correct. eBPF program would be using 8-byte read on 64-bit kernel
>>> and 4-byte read on 32-bit kernel. Same with access to ptrace fields
>>> and pretty much all other fields in the kernel. The program will be
>>> different on different kernels.
>>> Say, this bpf_context struct doesn't exist at all. The programs would
>>> still need to be different to walk in-kernel data structures...
>>
>> Hmm.  I guess this isn't so bad.
>>
>> What's the actual difficulty with using u64?  ISTM that, if the clang
>> front-end can't deal with u64, there's a bigger problem.  Or is it
>> something else I don't understand.
>
> clang/llvm has no problem with u64 :)
> This bpf_context struct for tracing is trying to answer the question:
>  'what's the most convenient way to access tracepoint arguments
> from a script'.
> When kernel code has something like:
>  trace_kfree_skb(skb, net_tx_action);
> the script needs to be able to access this 'skb' and 'net_tx_action'
> values through _single_ data structure.
> In this proposal they are ctx->arg1 and ctx->arg2.
> I've considered having different bpf_context's for every event, but
> the complexity explodes. I need to hack all event definitions and so on.
> imo it's better to move complexity to userspace, so program author
> or high level language abstracts these details.

I still don't understand why making them long instead of u64 is
helpful, though.  I feel like I'm missing obvious here.

-- 
Andy Lutomirski
AMA Capital Management, LLC
