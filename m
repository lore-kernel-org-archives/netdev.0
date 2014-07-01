From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC net-next 08/14] bpf: add eBPF verifier
Date: Tue, 1 Jul 2014 13:04:41 -0700
Message-ID: <CAMEtUuyc3+jrxG4r4=fk=Gc9OMhO8a2X1oyWPx1LsKzewVf01w@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-9-git-send-email-ast@plumgrid.com>
	<53B26BB0.90209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
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
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <53B26BB0.90209-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 1, 2014 at 1:05 AM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> w=
rote:
> On 06/28/2014 02:06 AM, Alexei Starovoitov wrote:
>>
>> Safety of eBPF programs is statically determined by the verifier, wh=
ich
>> detects:
>> - loops
>> - out of range jumps
>> - unreachable instructions
>> - invalid instructions
>> - uninitialized register access
>> - uninitialized stack access
>> - misaligned stack access
>> - out of range stack access
>> - invalid calling convention
>
> ...
>
>> More details in Documentation/networking/filter.txt
>>
>> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
>> ---
>
> ...
>>
>>   kernel/bpf/verifier.c               | 1431
>> +++++++++++++++++++++++++++++++++++
>
>
> Looking at classic BPF verifier which checks safety of BPF
> user space programs, it's roughly 200 loc. :-/

I'm not sure what's your point comparing apples to oranges.
=46or the record 1431 lines include ~200 lines worth of comments
and 200 lines of verbose prints. Without them rejected eBPF
program is black box. Users need a way to understand why
verifier rejected it.

>
>> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
>> new file mode 100644
>
> ...
>
>> +#define _(OP) ({ int ret =3D OP; if (ret < 0) return ret; })
>
> ...
>>
>> +       _(get_map_info(env, map_id, &map));
>
> ...
>>
>> +       _(size =3D bpf_size_to_bytes(bpf_size));
>
>
> Nit: such macros should be removed, please.

It may surely look unconventional, but alternative is to replace
every usage of _ macro with:
err =3D =E2=80=A6
if (err)
  return err;

and since this macro is used 38 times, it will add ~120 unnecessary
lines that will only make code much harder to follow.
I tried not using macro and results were not pleasing.
