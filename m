From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Mon, 5 Oct 2015 14:16:24 -0700
Message-ID: <CALCETrXUqYmwRhiFLnzWDrnVX5NdpoAnSggy8pxhzRPP86i5XA@mail.gmail.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
 <1444078101-29060-2-git-send-email-ast@plumgrid.com> <CAGXu5j+s+3Z6=WKKNGouNijNKcrq5o_n9-BD85Nabd-_GtL+ag@mail.gmail.com>
 <5612E7C4.1010306@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5612E7C4.1010306-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 5, 2015 at 2:12 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> On 10/5/15 2:00 PM, Kees Cook wrote:
>>
>> On Mon, Oct 5, 2015 at 1:48 PM, Alexei Starovoitov<ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
>> wrote:
>>>
>>> >In order to let unprivileged users load and execute eBPF programs
>>> >teach verifier to prevent pointer leaks.
>>> >Verifier will prevent
>>> >- any arithmetic on pointers
>>> >   (except R10+Imm which is used to compute stack addresses)
>>> >- comparison of pointers
>>> >- passing pointers to helper functions
>>> >- indirectly passing pointers in stack to helper functions
>>> >- returning pointer from bpf program
>>> >- storing pointers into ctx or maps
>>
>> Does the arithmetic restriction include using a pointer as an index to
>> a maps-based tail call? I'm still worried about pointer-based
>> side-effects.
>
>
> the array maps that hold FDs (BPF_MAP_TYPE_PROG_ARRAY and
> BPF_MAP_TYPE_PERF_EVENT_ARRAY) don't have lookup/update accessors
> from the program side, so programs cannot see or manipulate
> those pointers.
> For the former only bpf_tail_call() is allowed that takes integer
> index and jumps to it. And the latter map accessed with
> bpf_perf_event_read() that also takes index only (this helper
> is not available to socket filters anyway).
> Also bpf_tail_call() can only jump to the program of the same type.
> So I'm quite certain it's safe.

At some point there will be an unprivileged way to create a map,
though, and we don't want to let pointers get poked into the map.

Or am I misunderstanding?

--Andy
