From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH RFC v7 net-next 00/28] BPF syscall
Date: Wed, 27 Aug 2014 11:26:18 -0700
Message-ID: <CALCETrXAfZJTsF2nPFw55rHkfbNXKQuF8Frnq3e1wHEoGxLM4w@mail.gmail.com>
References: <1409106582-10095-1-git-send-email-ast@plumgrid.com>
 <CALCETrX2MzNxQ1ogt+Qx8iPjUe+z0gN6ZLwu9nAcZzTN+D+iYw@mail.gmail.com>
 <CAMEtUuwYqJVUuZxPBKy57NonWF+X_5vkNx4uSEx_d=-xBka1Kg@mail.gmail.com>
 <CALCETrWs9GRufGKxAoV628bh1f3HObkxNQuW3tYRt2rFwNAbxA@mail.gmail.com> <CAMEtUuw1n1HzAeyKFj9=nGq7RKZq7TADS-6M_BkHbTsWJ_Gm-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuw1n1HzAeyKFj9=nGq7RKZq7TADS-6M_BkHbTsWJ_Gm-Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 26, 2014 at 9:57 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> On Tue, Aug 26, 2014 at 9:49 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>> On Tue, Aug 26, 2014 at 9:35 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>> On Tue, Aug 26, 2014 at 8:56 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>>> On Aug 26, 2014 7:29 PM, "Alexei Starovoitov" <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>>>>
>>>>> Hi Ingo, David,
>>>>>
>>>>> posting whole thing again as RFC to get feedback on syscall only.
>>>>> If syscall bpf(int cmd, union bpf_attr *attr, unsigned int size) is ok,
>>>>> I'll split them into small chunks as requested and will repost without RFC.
>>>>
>>>> IMO it's much easier to review a syscall if we just look at a
>>>> specification of what it does.  The code is, in some sense, secondary.
>>>
>>> 'specification of what it does'... hmm, you mean beyond what's
>>> there in commit logs and in Documentation/networking/filter.txt ?
>>> Aren't samples at the end give an idea on 'what it does'?
>>> I'm happy to add 'specification', I just don't understand yet what
>>> it suppose to talk about beyond what's already written.
>>> I understand that the patches are missing explanation on 'why'
>>> the syscall is being added, but I don't think it's what you're asking...
>>
>> I mean a hopefully short document that defines what the syscall does.
>> It should be precise enough that one could, in principle, implement
>> the syscall just by reading the document and that one could use the
>> syscall just by reading the document.
>>
>> Given that there's a whole instruction set to go with it, it may end
>> up being moderately complicated or saying things like "see this other
>> thing for a description of the instruction set" and "there are some
>> extensible sets of functions you can call with it".
>
> I'm still lost.
>
> Here is the quote from Documentation/networking/filter.txt
> "
> 'maps' is a generic storage of different types for sharing data between kernel
> and userspace.
>
> The maps are accessed from user space via BPF syscall,
> which has commands:
> - create a map with given type and attributes
>   map_fd = bpf(BPF_MAP_CREATE, union bpf_attr *attr, u32 size)
>   using attr->map_type, attr->key_size, attr->value_size, attr->max_entries
>   returns process-local file descriptor or negative error
>
> - lookup key in a given map
>   err = bpf(BPF_MAP_LOOKUP_ELEM, union bpf_attr *attr, u32 size)
>   using attr->map_fd, attr->key, attr->value
>   returns zero and stores found elem into value or negative error
>
> - create or update key/value pair in a given map
>   err = bpf(BPF_MAP_UPDATE_ELEM, union bpf_attr *attr, u32 size)
>   using attr->map_fd, attr->key, attr->value
>   returns zero or negative error
>
> - find and delete element by key in a given map
>   err = bpf(BPF_MAP_DELETE_ELEM, union bpf_attr *attr, u32 size)
>   using attr->map_fd, attr->key
>
> - to delete map: close(fd)
>   Exiting process will delete maps automatically
>
> userspace programs uses this API to create/populate/read
> maps that eBPF programs are concurrently updating.
> "
> and more in commit log:
> "
> - load eBPF program
>   fd = bpf(BPF_PROG_LOAD, union bpf_attr *attr, u32 size)
>
>   where 'attr' is
>   struct {
>       enum bpf_prog_type prog_type;
>       __u32 insn_cnt;
>       struct bpf_insn __user *insns;
>       const char __user *license;
>   };
>   insns - array of eBPF instructions
>   license - must be GPL compatible to call helper functions marked gpl_only
>
> - unload eBPF program
>   close(fd)
> "
>
> Isn't it short and describes what it does?
> Do you want me to describe what eBPF program can do?

The problem is that everyone needs to dig around a very long patch
series to find it.  Since you're asking for a review of a syscall, it
would be nice to have everything needed to review whether the syscall
is a good idea in its present form in one place and to keep the amount
of email under control.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC
