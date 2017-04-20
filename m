From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH net-next v6 05/11] seccomp: Split put_seccomp_filter()
 with put_seccomp()
Date: Wed, 19 Apr 2017 18:54:33 -0700
Message-ID: <CAGXu5jLaYXE14AKL5Za5BKUJx9qBdcsdyJEzh5ffN4BUxkCzBA@mail.gmail.com>
References: <20170328234650.19695-1-mic@digikod.net> <20170328234650.19695-6-mic@digikod.net>
 <CAGXu5jK3awbLYJTq9keb7oafUxU=_Ec9uMUHNWQH7skEhEg7WQ@mail.gmail.com>
 <9b420ecc-f062-8ab3-0b18-e09c60a00c6a@digikod.net> <96024881-1bcc-33af-6285-d9a904de963e@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
        Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Shuah Khan <shuah-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Will Drewry <wa
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <96024881-1bcc-33af-6285-d9a904de963e-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 19, 2017 at 3:18 PM, Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>=
 wrote:
>
> On 19/04/2017 00:47, Micka=C3=ABl Sala=C3=BCn wrote:
>>
>> On 19/04/2017 00:23, Kees Cook wrote:
>>> On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>>>> The semantic is unchanged. This will be useful for the Landlock
>>>> integration with seccomp (next commit).
>>>>
>>>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
>>>> Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
>>>> Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
>>>> Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
>>>> ---
>>>>  include/linux/seccomp.h |  4 ++--
>>>>  kernel/fork.c           |  2 +-
>>>>  kernel/seccomp.c        | 18 +++++++++++++-----
>>>>  3 files changed, 16 insertions(+), 8 deletions(-)
>>>>
>>>> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
>>>> index ecc296c137cd..e25aee2cdfc0 100644
>>>> --- a/include/linux/seccomp.h
>>>> +++ b/include/linux/seccomp.h
>>>> @@ -77,10 +77,10 @@ static inline int seccomp_mode(struct seccomp *s)
>>>>  #endif /* CONFIG_SECCOMP */
>>>>
>>>>  #ifdef CONFIG_SECCOMP_FILTER
>>>> -extern void put_seccomp_filter(struct task_struct *tsk);
>>>> +extern void put_seccomp(struct task_struct *tsk);
>>>>  extern void get_seccomp_filter(struct task_struct *tsk);
>>>>  #else  /* CONFIG_SECCOMP_FILTER */
>>>> -static inline void put_seccomp_filter(struct task_struct *tsk)
>>>> +static inline void put_seccomp(struct task_struct *tsk)
>>>>  {
>>>>         return;
>>>>  }
>>>> diff --git a/kernel/fork.c b/kernel/fork.c
>>>> index 6c463c80e93d..a27d8e67ce33 100644
>>>> --- a/kernel/fork.c
>>>> +++ b/kernel/fork.c
>>>> @@ -363,7 +363,7 @@ void free_task(struct task_struct *tsk)
>>>>  #endif
>>>>         rt_mutex_debug_task_free(tsk);
>>>>         ftrace_graph_exit_task(tsk);
>>>> -       put_seccomp_filter(tsk);
>>>> +       put_seccomp(tsk);
>>>>         arch_release_task_struct(tsk);
>>>>         if (tsk->flags & PF_KTHREAD)
>>>>                 free_kthread_struct(tsk);
>>>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>>>> index 65f61077ad50..326f79e32127 100644
>>>> --- a/kernel/seccomp.c
>>>> +++ b/kernel/seccomp.c
>>>> @@ -64,6 +64,8 @@ struct seccomp_filter {
>>>>  /* Limit any path through the tree to 256KB worth of instructions. */
>>>>  #define MAX_INSNS_PER_PATH ((1 << 18) / sizeof(struct sock_filter))
>>>>
>>>> +static void put_seccomp_filter(struct seccomp_filter *filter);
>>>
>>> Can this be reorganized easily to avoid a forward-declaration?
>>
>> I didn't want to move too much code but I will.
>>
>>>
>>>> +
>>>>  /*
>>>>   * Endianness is explicitly ignored and left for BPF program authors =
to manage
>>>>   * as per the specific architecture.
>>>> @@ -314,7 +316,7 @@ static inline void seccomp_sync_threads(void)
>>>>                  * current's path will hold a reference.  (This also
>>>>                  * allows a put before the assignment.)
>>>>                  */
>>>> -               put_seccomp_filter(thread);
>>>> +               put_seccomp_filter(thread->seccomp.filter);
>>>>                 smp_store_release(&thread->seccomp.filter,
>>>>                                   caller->seccomp.filter);
>>>>
>>>> @@ -476,10 +478,11 @@ static inline void seccomp_filter_free(struct se=
ccomp_filter *filter)
>>>>         }
>>>>  }
>>>>
>>>> -/* put_seccomp_filter - decrements the ref count of tsk->seccomp.filt=
er */
>>>> -void put_seccomp_filter(struct task_struct *tsk)
>>>> +/* put_seccomp_filter - decrements the ref count of a filter */
>>>> +static void put_seccomp_filter(struct seccomp_filter *filter)
>>>>  {
>>>> -       struct seccomp_filter *orig =3D tsk->seccomp.filter;
>>>> +       struct seccomp_filter *orig =3D filter;
>>>> +
>>>>         /* Clean up single-reference branches iteratively. */
>>>>         while (orig && atomic_dec_and_test(&orig->usage)) {
>>>>                 struct seccomp_filter *freeme =3D orig;
>>>> @@ -488,6 +491,11 @@ void put_seccomp_filter(struct task_struct *tsk)
>>>>         }
>>>>  }
>>>>
>>>> +void put_seccomp(struct task_struct *tsk)
>>>> +{
>>>> +       put_seccomp_filter(tsk->seccomp.filter);
>>>> +}
>>>> +
>>>>  static void seccomp_init_siginfo(siginfo_t *info, int syscall, int re=
ason)
>>>>  {
>>>>         memset(info, 0, sizeof(*info));
>>>> @@ -914,7 +922,7 @@ long seccomp_get_filter(struct task_struct *task, =
unsigned long filter_off,
>>>>         if (copy_to_user(data, fprog->filter, bpf_classic_proglen(fpro=
g)))
>>>>                 ret =3D -EFAULT;
>>>>
>>>> -       put_seccomp_filter(task);
>>>> +       put_seccomp_filter(task->seccomp.filter);
>>>>         return ret;
>>>
>>> I don't like that the arguments to get_seccomp_filter() and
>>> put_seccomp_filter() are now different. I think they should match for
>>> readability.
>>
>> OK, I can do that.
>>
>
> Kees, can I send this as a separate patch?

Sure! Though I still think the argument to get/put_seccomp_filter()
should be task_struct.

-Kees

--=20
Kees Cook
Pixel Security
