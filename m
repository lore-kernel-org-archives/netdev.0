From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH RFC net-next 03/14] bpf: introduce syscall(BPF, ...) and
 BPF maps
Date: Sat, 28 Jun 2014 18:52:20 -0700
Message-ID: <CALCETrWq+=Q3G2Smjd2RYES42UagpmD0EKxFM+jNufi6_qitWg@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
 <1403913966-4927-4-git-send-email-ast@plumgrid.com> <CALCETrV3WLBmHewCZgfhCkjODWfq_byRg6sF7HpqZ6n9BVMBVQ@mail.gmail.com>
 <CAMEtUuzWs+MbSOGGD-Rc01DHKASa4GxbHdtCrSCLit4cUM35mA@mail.gmail.com>
 <CALCETrWy6=dzTycy-ckiMR92+nQeqAWp_Hw=hi__VSzVWZ43Ag@mail.gmail.com>
 <CAMEtUuwRf--qyPu3rKB7-57KAu2NdsQdEpVRckqabmf61g+h-g@mail.gmail.com>
 <CALCETrUoOTtQ1R1A8Ak35fxHxaFTPHWP6oZWnXDVLKa_ESziWw@mail.gmail.com> <CAMEtUuzS=9Y_ZjigofvQ5d3=89RS=+d8-WGPk9VVSMc3qawWsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuzS=9Y_ZjigofvQ5d3=89RS=+d8-WGPk9VVSMc3qawWsw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 28, 2014 at 1:49 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> On Sat, Jun 28, 2014 at 8:34 AM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>> On Fri, Jun 27, 2014 at 11:43 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>> On Fri, Jun 27, 2014 at 11:25 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>>> On Fri, Jun 27, 2014 at 10:55 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>>>> On Fri, Jun 27, 2014 at 5:16 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>>>>> On Fri, Jun 27, 2014 at 5:05 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>>>>>> BPF syscall is a demux for different BPF releated commands.
>>>>>>>
>>>>>>> 'maps' is a generic storage of different types for sharing data between kernel
>>>>>>> and userspace.
>>>>>>>
>>>>>>> The maps can be created/deleted from user space via BPF syscall:
>>>>>>> - create a map with given id, type and attributes
>>>>>>>   map_id = bpf_map_create(int map_id, map_type, struct nlattr *attr, int len)
>>>>>>>   returns positive map id or negative error
>>>>>>>
>>>>>>> - delete map with given map id
>>>>>>>   err = bpf_map_delete(int map_id)
>>>>>>>   returns zero or negative error
>>>>>>
>>>>>> What's the scope of "id"?  How is it secured?
>>>>>
>>>>> the map and program id space is global and it's cap_sys_admin only.
>>>>> There is no pressing need to do it with per-user limits.
>>>>> So the whole thing is root only for now.
>>>>>
>>>>
>>>> Hmm.  This may be unpleasant if you ever want to support non-root or
>>>> namespaced operation.
>>>
>>> I think it will be easy to extend it per namespace when we lift
>>> root-only restriction. It will be seamless without user api changes.
>>>
>>
>> It might be seamless, but I'm not sure it'll be very useful.  See below.
>>
>>>> How hard would it be to give these things fds?
>>>
>>> you mean programs/maps auto-terminate when creator process
>>> exits? I thought about it and it's appealing at first glance, but
>>> doesn't fit the model of existing tracepoint events which are global.
>>> The programs attached to events need to live without 'daemon'
>>> hanging around. Therefore I picked 'kernel module'- like method.
>>
>> Here are some things I'd like to be able to do:
>>
>>  - Load an eBPF program and use it as a seccomp filter.
>>
>>  - Create a read-only map and reference it from a seccomp filter.
>>
>>  - Create a data structure that a seccomp filter can write but that
>> the filtered process can only read.
>>
>>  - Create a data structure that a seccomp filter can read but that
>> some other trusted process can write.
>>
>>  - Create a network filter of some sort and give permission to
>> manipulate a list of ports to an otherwise untrusted process.
>>
>> The first four of these shouldn't require privilege.
>>
>> All of this fits nicely into a model where all of the eBPF objects
>> (filters and data structures) are represented by fds.  Read access to
>> the fd lets you read (or execute eBPF programs).  Write access to the
>> fd lets you write.  You can send them around naturally using
>> SCM_RIGHTS, and you can create deprivileged versions by reopening the
>> objects with less access.
>
> Sorry I don't like 'fd' direction at all.
> 1. it will make the whole thing very socket specific and 'net' dependent.
> but the goal here is to be able to use eBPF for tracing in embedded
> setups. So it's gotta be net independent.
> 2. sockets are already overloaded with all sorts of stuff. Adding more
> types of sockets will complicate it a lot.
> 3. and most important. read/write operations on sockets are not
> done every nanosecond, whereas lookup operations on bpf maps
> are done every dozen instructions, so we cannot have any overhead
> when accessing maps.
> In other words the verifier is done as static analyzer. I moved all
> the complexity to verify time, so at run-time the programs are as
> fast as possible. I'm strongly against run-time checks in critical path,
> since they kill performance and make the whole approach a lot less usable.

I may have described my suggestion poorly.  I'm suggesting that all of
these global ids be replaced *for userspace's benefit* with fds.  That
is, a map would have an associated struct inode, and, when you load an
eBPF program, you'd pass fds into the kernel instead of global ids.
The kernel would still compile the eBPF program to use the global ids,
though.

This should have no effect at all on the execution of eBPF programs.
eBPF programs wouldn't be able to look up fds at runtime, and this
should work without CONFIG_NET.

--Andy
