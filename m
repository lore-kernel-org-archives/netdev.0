From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RFC v3 19/22] landlock: Add interrupted origin
Date: Wed, 14 Sep 2016 18:19:14 -0700
Message-ID: <CALCETrWmp33g0_adWcLXLuQe7R2EeLchKGivQnEsK5A4nAwTfw@mail.gmail.com>
References: <20160914072415.26021-1-mic@digikod.net> <20160914072415.26021-20-mic@digikod.net>
 <CALCETrUyqZEcJansuN=NX04CXv4ROtNqB25YZw7mBGuu43DFew@mail.gmail.com> <57D9CBD3.7030100@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org"
        <kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>,
        Linux API <linu
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57D9CBD3.7030100-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 3:14 PM, Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>=
 wrote:
>
> On 14/09/2016 20:29, Andy Lutomirski wrote:
>> On Wed, Sep 14, 2016 at 12:24 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>>> This third origin of hook call should cover all possible trigger paths
>>> (e.g. page fault). Landlock eBPF programs can then take decisions
>>> accordingly.
>>>
>>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
>>> Cc: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>>> Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
>>> Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
>>> Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
>>> ---
>>
>>
>>>
>>> +       if (unlikely(in_interrupt())) {
>>
>> IMO security hooks have no business being called from interrupts.
>> Aren't they all synchronous things done by tasks?  Interrupts are
>> driver things.
>>
>> Are you trying to check for page faults and such?
>
> Yes, that was the idea you did put in my mind. Not sure how to deal with
> this.
>

It's not so easy, unfortunately.  The easiest reliable way might be to
set a TS_ flag on all syscall entries when TIF_SECCOMP or similar is
set.

--Andy
