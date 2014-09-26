From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: eBPF verifier thoughts (Re: [PATCH v15 net-next 00/11] eBPF
 syscall, verifier, testsuite)
Date: Fri, 26 Sep 2014 16:13:47 -0700
Message-ID: <CAMEtUuw4-7GyjGUC4yfCCyQTVZAiG-Fxa5gRdj-UA1BJ2V381A@mail.gmail.com>
References: <CALCETrVrHHxGo1RkPu+9LVnPo9XY9yYnJzg2ot0zOgoBspzbOQ@mail.gmail.com>
	<CAMEtUuyt9RASKZ4NeqK_OUYNN8QT6P20+kjcwywchur6QXSt0A@mail.gmail.com>
	<CALCETrXS5KBHm-3Fz031VFPpTHC_BDOLd_zNB6DjCidZa5-x2A@mail.gmail.com>
	<CAMEtUux-WFOGABTrWW=BGUstE=Zz6agXTGCGrRJtNXDfRmx-5A@mail.gmail.com>
	<CALCETrVLtJOYkHwsmwueZ7jsSgrNED564W+m4FmMZJZL-836mg@mail.gmail.com>
	<CAMEtUuxq7oNmDAHZ+1t4Vd-QhW6SV7eoM_juxXGEDJBF3Nfu6A@mail.gmail.com>
	<CALCETrWcmZVmRZARM_s9S-zZ4Xm_TcxRrzJWGwL0O9ySmVgr5A@mail.gmail.com>
	<CAMEtUuzQF+3uWFWmj5nSdYoJfo0W2F0wkvoyc4pP--EH3O_jYA@mail.gmail.com>
	<CALCETrUP=LE2QNzYL8LCukeuWeumOn0bm0eqYscc7GJqq45oYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrUP=LE2QNzYL8LCukeuWeumOn0bm0eqYscc7GJqq45oYA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 26, 2014 at 3:41 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> On Fri, Sep 26, 2014 at 3:26 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>> On Fri, Sep 26, 2014 at 3:07 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>> On Fri, Sep 26, 2014 at 3:03 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>>> On Fri, Sep 26, 2014 at 2:47 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>>>>
>>>>> Can't you just disallow the 1-byte write to the stack?
>>>>
>>>> of course not.
>>>> That would be extremely limiting to users.
>>>> Can you actually see yourself living with stack that only
>>>> allows 8-byte writes/reads?
>>>> The stack usage will increase a lot, since all char/short
>>>> stack variables will become 8-byte...
>>>
>>> How about requiring that sub-8-byte stack accesses only be to integer slots?
>>
>> you mean to reject the sub-8-byte write early if it's going
>> into space where pointers were stored?
>> That will limit stack reuse.
>> gcc/llvm generate code where the same stack location
>> is used by different variables during life of the function.
>> So if I reject the write early, it will break otherwise valid
>> programs.
>
> I think that a sub-8-byte write to an integer slot should leave it as
> an integer and a sub-8-byte write to a non-integer slot should turn
> that slot into an integer (if conversions to integer are permitted) or
> be rejected otherwise.  gcc/llvm could emit an 8-byte write first, as
> needed, to make this valid.

I don't think the above will work.

> Alternatively, an integer stack slot could have a bitmask indicating
> which bytes are valid.

but this one might. Let me think about it more.
Note verifier, as it stands, is using 12Kbyte of temporary
memory to track stack with byte granularity.
(it's freed as soon as verifier finishes)
This bitmask optimization, best case, will reduce it to 1.5Kbyte
at the cost of extra complexity. I'll play with this idea to
see whether this trade off is actually worth doing.
Also note that there are indirect stack reads
(see check_func_arg() -> check_stack_boundary())
used to verify that N bytes were initialized in stack
before calling into helper function.
Also in the future I was planning to allow
indirect stack write, so that helper function can
store stuff into program stack. This indirect accesses
are crossing 8-byte boundaries, so would need special
care with bitmask optimization.
We need to carefully weight all pros and cons.
imo this memory usage during verification is not a big deal,
but of course we should not waste it. I'll see what can be done.

In any case, we're talking about incremental improvements
on top of current stuff, right?
