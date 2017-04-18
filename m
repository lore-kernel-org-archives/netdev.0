From: Kees Cook <keescook@chromium.org>
Subject: Re: [kernel-hardening] [PATCH net-next v6 06/11] seccomp,landlock:
 Handle Landlock events per process hierarchy
Date: Tue, 18 Apr 2017 15:54:41 -0700
Message-ID: <CAGXu5j+jEiRHmbr4_4NXf0X=THGbzj1TsbGDRdVk8UMQ0ipvQQ@mail.gmail.com>
References: <20170328234650.19695-1-mic@digikod.net> <20170328234650.19695-7-mic@digikod.net>
 <CAEiveUcp6xpUW764zupy8ekttnQGaonXFn-JEFg7nhXUKzenDg@mail.gmail.com> <b0662712-53f4-1293-aa61-f0455301d7cc@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Djalal Harouni <tixxdz@gmail.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <b0662712-53f4-1293-aa61-f0455301d7cc@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 31, 2017 at 2:15 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
>
>
> On 29/03/2017 12:35, Djalal Harouni wrote:
>> On Wed, Mar 29, 2017 at 1:46 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.n=
et> wrote:
>
>>> @@ -25,6 +30,9 @@ struct seccomp_filter;
>>>  struct seccomp {
>>>         int mode;
>>>         struct seccomp_filter *filter;
>>> +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK=
)
>>> +       struct landlock_events *landlock_events;
>>> +#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
>>>  };
>>
>> Sorry if this was discussed before, but since this is mean to be a
>> stackable LSM, I'm wondering if later you could move the events from
>> seccomp, and go with a security_task_alloc() model [1] ?
>>
>> Thanks!
>>
>> [1] http://kernsec.org/pipermail/linux-security-module-archive/2017-Marc=
h/000184.html
>>
>
> Landlock use the seccomp syscall to attach a rule to a process and using
> struct seccomp to store this rule make sense. There is currently no way
> to store multiple task->security, which is needed for a stackable LSM
> like Landlock, but we could move the events there if needed in the future=
.

It does stand out to me that the only thing landlock is using seccomp
for is its syscall... :P

-Kees

--=20
Kees Cook
Pixel Security
