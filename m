From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v13 net-next 07/11] bpf: verifier (add ability to receive
 verification log)
Date: Thu, 18 Sep 2014 08:24:26 -0700
Message-ID: <CAMEtUuykgG70sP0tAmovLvPxgjwaR8h=R-c6Tyo6m96+Lg3sXQ@mail.gmail.com>
References: <1410914370-29883-1-git-send-email-ast@plumgrid.com>
	<1410914370-29883-8-git-send-email-ast@plumgrid.com>
	<54192F66.8020200@redhat.com>
	<CAMEtUuxK68ZoJ-izjLoygv0f+rLtPmMLUUq1=BJ+_ZBGfynkdA@mail.gmail.com>
	<5419BED8.5020309@redhat.com>
	<5419DE51.1060904@redhat.com>
	<CAMEtUuzhcmZiYZL8TR008or8uaefDBrEKDjqA-tOrRLEZsm95A@mail.gmail.com>
	<CAMEtUuw0aDPpQhd13ssk2PDLffBJNeef9jicOnhQLH6KtJ8gsQ@mail.gmail.com>
	<541A7F35.2010804@redhat.com>
	<CAMEtUuyZCHh7SGeLF+g0ye3OrEFWnTZCn3SBeK0-8qz-y8U30w@mail.gmail.com>
	<541AF11C.9050405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
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
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <541AF11C.9050405-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 18, 2014 at 7:50 AM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 09/18/2014 04:34 PM, Alexei Starovoitov wrote:
>>
>> On Wed, Sep 17, 2014 at 11:44 PM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> wrote:
>
> ...
>>>
>>> Sure, you will never get a full compatibility on that regard
>>> while backwards compatibility needs to be guaranteed on the
>>> other hand. I looked at perf_copy_attr() implementation and I
>>> think that we should mimic it in a very similar way as it
>>> exactly solves what we need.
>>>
>>> For example, it will return with -EINVAL for (size > PAGE_SIZE)
>>> and (size < PERF_ATTR_SIZE_VER0) where PAGE_SIZE has been chosen
>>> as an arbitrary hard upper limit where it is believed that it will
>>> never grow beyond that large limit in future.
>>>
>>> So this is a more loose constraint than what we currently do,
>>> that is, -EINVAL on (size > sizeof(attr)) where attr is the
>>> currently known size of a specific kernel. That would at least
>>> be a start, you won't be able to cover everything though, but
>>> it would allow to address the issue raised when running with
>>> a basic feature set.
>>
>>
>> you missed my point. We should not 'do a start', since it
>> doesn't help user space in the long run and only makes
>> kernel more complex.
>
>
> Sorry, I don't think I missed your point. But if you see things
> differently, fair enough, it was just a suggestion.

now you probably think I'm shutting you up. Sorry. Was not
my intention. Let me rephrase what I meant:
I think we should decide right now whether
'new user + old kernel' is really a problem we're going to
solve or not. If we decide to solve it, we need to have
a plan to solve it all the way. Partial fix for size of bpf_attr
is not a plan. It's something that is not addressing the problem
completely. Little bit of help is not useful for userspace. It
would need to deal with new types, verifier differences and
other things that I mentioned earlier. So we either decide
that we're going to spend time to solve all of them (not
necessarily today, but over long haul) or we're not doing
any of it.
