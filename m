From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH RFC net-next 03/14] bpf: introduce syscall(BPF, ...) and
 BPF maps
Date: Fri, 4 Jul 2014 08:17:25 -0700
Message-ID: <CALCETrWQnQS=jjuhQzxM9YMhGk-fJ1oNetdPuZ0v4yujBLZ+fA@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
 <1403913966-4927-4-git-send-email-ast@plumgrid.com> <CALCETrV3WLBmHewCZgfhCkjODWfq_byRg6sF7HpqZ6n9BVMBVQ@mail.gmail.com>
 <CAMEtUuzWs+MbSOGGD-Rc01DHKASa4GxbHdtCrSCLit4cUM35mA@mail.gmail.com>
 <CALCETrWy6=dzTycy-ckiMR92+nQeqAWp_Hw=hi__VSzVWZ43Ag@mail.gmail.com>
 <CAMEtUuwRf--qyPu3rKB7-57KAu2NdsQdEpVRckqabmf61g+h-g@mail.gmail.com>
 <CALCETrUoOTtQ1R1A8Ak35fxHxaFTPHWP6oZWnXDVLKa_ESziWw@mail.gmail.com>
 <CAMEtUuzS=9Y_ZjigofvQ5d3=89RS=+d8-WGPk9VVSMc3qawWsw@mail.gmail.com>
 <CALCETrWq+=Q3G2Smjd2RYES42UagpmD0EKxFM+jNufi6_qitWg@mail.gmail.com>
 <CAMEtUuyKY=haqP11VgXHdfHBkqfB-KxuswygUd7hDPLkOFz9HQ@mail.gmail.com>
 <CALCETrW3=idHOKF56d94suiA0NoiUGwr7pENm13q6=1XMbBPdw@mail.gmail.com>
 <CAMEtUuyX-tybpMEW=f-00qgq9h3AcHovLNW0_bak3oT4Oj3FuA@mail.gmail.com>
 <CALCETrWpA5M74pKJLFJ0t-2hi2TXMi_BV6DbJMmdDOJyOoHOyg@mail.gmail.com>
 <CAMEtUuzHrzyUG1nie5cWzGZYTDTnqL7vPvAmPZdie_uSM_wqRA@mail.gmail.com>
 <CALCETrW5WitpzcFmkGDwR6U=qOwCkOfQMy=XOtQTuHs-942Drw@mail.gmail.com> <CAMEtUuzkVANM341xPTKH1bNVNuK6TQcyqsdZdkGWausLT5Qj6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
In-Reply-To: <CAMEtUuzkVANM341xPTKH1bNVNuK6TQcyqsdZdkGWausLT5Qj6A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 2, 2014 at 7:29 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> w=
rote:
> On Wed, Jul 2, 2014 at 6:43 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>=
 wrote:
>> On Tue, Jul 1, 2014 at 10:33 PM, Alexei Starovoitov <ast-uqk4Ao+rVK7QFizaE/u3fw@public.gmane.org=
m> wrote:
>>> I want to avoid string names, since they will force new 'strtab', '=
symtab'
>>> sections in the programs/maps and will uglify the user interface qu=
ite a bit.
>>
>> To be fair, you really need to imitate ELF here.  A very simple
>> relocation-like table should do the trick.
>
> simple.. right :) I do see the amount of struggle you have with
> binutils and vdso.
> I really don't want to add relocation unless this is last resort.
> Especially since it can be solved without it.
> I don't think I explained it enough in my last email=E2=80=A6 trying =
again:
>
>>> Back in september one loadable unit was: one eBPF program + set of =
maps,
>>> but tracing requirements forced a change, since multiple programs n=
eed
>>> to access the same map and maps may need to be pre-populated before
>>> the programs start executing, so I've split maps and programs into =
mostly
>>> independent entities, but programs still need to think of maps as l=
ocal:
>>> For example I want to do a skb leak check 'tracing filter':
>>> - attach this program to kretprobe of __alloc_skb():
>>>   u64 key =3D (u64) skb;
>>>   u64 value =3D bpf_get_time();
>>>   bpf_update_map_elem(1/*const_map_id*/, &key, &value);
>>> - attach this program to consume_skb and kfree_skb tracepoints:
>>>   u64 key =3D (u64) skb;
>>>   bpf_delete_map_elem(1/*const_map_id*/, &key);
>>> - and have user space do:
>>>   prior to loading:
>>>   bpf_create_map(1/*map_id*/, 8/*key_size*/, 8/*value*/, 1M /*max_e=
ntries*/)
>>>   and then periodically iterate the map to see whether any skb stay=
ed
>>>   in the map for too long.
>>>
>>> Programs need to be written with hard coded map_ids otherwise usabi=
lity
>>> suffers, so I did global 32-bit id in this RFC
>>>, but this indeed doesn't work
>>
>> Really?  That will mean that you have to edit the source of your
>> filter program if the small integer map number you chose conflicts
>> with another program.  That sounds unpleasant.
>
> unpleasant. exactly. that's why I'm proposing per-process local map-i=
d,
> so that programs don't need to be edited.
>
>>> for unprivileged chrome browser unless programs are previously load=
ed
>>> by root and chrome only does attach to seccomp.
>>>
>>> So here is the non-root bpf syscall interface I'm thinking about:
>>>
>>> ufd =3D bpf_create_map(map_id, key_size, value_size, max_entries);
>>>
>>> it will create a global map in the system which will be accessible
>>> in this process via 'ufd'. Internally this 'ufd' will be assigned g=
lobal map_id
>>> and process-local map_id that was passed as a 1st argument.
>>> To do update/lookup the process will use bpf_map_xxx_elem(ufd,=E2=80=
=A6)
>>>
>>
>> Erk.  Unprivileged programs shouldn't be able to allocate global ids
>> of their choosing, especially if privileged programs can also do it.
>> Otherwise unprivileged programs can force a collision and possibly
>> steal information.
>
> of course. that's not what said.
>
>>> Then to load eBPF program the process will do:
>>> ufd =3D bpf_prog_load(prog_type, ebpf_insn_array, license)
>>> and instructions will be referring to maps via local map_id that
>>> was hard coded as part of the program.
>>
>> I think relocations would be must prettier than per-process map id t=
ables.
>
> I think per process map_id are much cleaner.
>
> non-root API:
>
> ufd =3D bpf_create_map(local_map_id,=E2=80=A6 )
> bpf_map_update/delete/lookup_elem(ufd,=E2=80=A6)
> ufd =3D bpf_prog_load(insns)
> close(ufd)
>
> root only API:
>
> global_id =3D bpf_get_id(ufd) // returns either map or prog global id
> bpf_map_delete(global_map_id)
> bpf_prog_unload(global_prog_id)
>
> Details:
>
> ufd =3D bpf_create_map(local_map_id, ...);
>
> local_map_id - process local map_id
> (this id is used to access maps from eBPF program loaded by this proc=
ess)
>
> ufd - process local file descriptor
> (used to update/lookup maps from this process)
>
> global_map_id =3D bpf_get_id(ufd)
> this is root only call to get global_ids and pass them to global even=
ts
> like tracing.
>
> global ids will only be seen by root. There is no way for root or non=
-root
> to influence id ranges.
>
>>> Beyond the normal create_map, update/lookup/delete, load_prog
>>> operations (that are accessible to both root and non-root), the roo=
t user
>>> gains one more operations: bpf_get_global_id(ufd) that returns
>>> global map_id or prog_id. This id can be attached to global events
>>> like tracing. Non-root users lose ability to do delete_map and
>>> unload_prog (they do close(ufd) instead), so this ops are for root
>>> only and operate on global ids.
>>> This is the cleanest way I could think of to combine non-root
>>> security, per-process id and global id all in one API. Thoughts?
>>
>> I think I'm okay with this part, although an interface to get a map =
fd
>> given some reference to the program (in sysfs) that uses it would al=
so
>> work and maybe be more straightforward.
>
> If you meant debugfs, then yes. I'm planning to add a way for root
> to see all loaded programs and maps (similar to /proc as lsmod does),
> and then do bpf_map_delete/bpf_prog_unload (similar to rmmod)
>
> setsockopt and seccomp will be non-root and programs will go
> through additional dont_leak_pointers check in verifier.
> tracing/dtrace will be for root only, since they would need to attach
> to global events.
>
> I think it will be cleaner once I finish fd conversion as a patch.

OK

=46WIW, per-process local id maps sound almost equivalent to relocation=
s
-- the latter could be as simple as an extra nlattr giving a list of
pairs of (per-eBPF-program id, fd).

My current binutils mess is mainly just because I'm trying to do
something weird with an old, old file format that needs to support
lots of legacy tools.  You won't have that problem.

--Andy
