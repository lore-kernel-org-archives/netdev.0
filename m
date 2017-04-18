From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH net-next v6 10/11] bpf,landlock: Add tests for Landlock
Date: Tue, 18 Apr 2017 16:59:03 -0700
Message-ID: <CAGXu5jJp2Nt47EDL=wvqUuk4kTcExBqm1KbQtFOL_BTE+rybjQ@mail.gmail.com>
References: <20170328234650.19695-1-mic@digikod.net> <20170328234650.19695-11-mic@digikod.net>
 <CAGXu5j+-sFD5z2daPjvM0Q8vM=g9ZtwJ7-ZakqoUcjsiAD=+1A@mail.gmail.com> <f5291c43-100f-a06c-6c64-c718a02822df@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel@vger.kernel.org>,
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
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wa
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <f5291c43-100f-a06c-6c64-c718a02822df@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 18, 2017 at 4:53 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
> On 19/04/2017 01:16, Kees Cook wrote:
>> On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.n=
et> wrote:
>>> --- /dev/null
>>> +++ b/tools/testing/selftests/landlock/Makefile
>>> @@ -0,0 +1,47 @@
>>> +LIBDIR :=3D ../../../lib
>>> +BPFOBJ :=3D $(LIBDIR)/bpf/bpf.o
>>> +LOADOBJ :=3D ../../../../samples/bpf/bpf_load.o
>>
>> Is the selftest tarball creation tool okay with this? IIRC, it should
>> be fine since it'll be a built object already, but it's a random
>> thought I had while looking at this.
>
> Hum, I'll check since it's the same for BPF tests.

Okay, cool.

>>> +# asm/sysreg.h - inline assembly used by it is incompatible with llvm.
>>> +# But, there is no easy way to fix it, so just exclude it since it is
>>> +# useless for BPF samples.
>>> +$(obj)/%.o: $(src)/%.c
>>> +       $(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
>>> +               -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-po=
inter-sign \
>>> +               -Wno-compare-distinct-pointer-types \
>>> +               -Wno-gnu-variable-sized-type-not-at-end \
>>> +               -Wno-tautological-compare \
>>> +               -O2 -emit-llvm -c $< -o -| $(LLC) -march=3Dbpf -filetyp=
e=3Dobj -o $@
>>
>> Is clang required for the samples and the selftests? That needs to be
>> avoided... there needs to be a way to show people how to build a
>> landlock rule without requiring clang.
>
> I can rewrite this tests without requiring clang but it is already
> required for BPF tests=E2=80=A6

So, I guess it's not a big deal for selftests (but it'd be nice, even
for BPF), but I think at least the samples/ should have examples on
how to do it "by hand", etc. Not everyone will build stuff with clang,
and it'd be good to make landlock as available as possible.

>>> +#define ASSERT_STEP(cond) \
>>> +       { \
>>> +               step--; \
>>> +               if (!(cond)) \
>>> +                       _exit(step); \
>>> +       }
>>
>> Can you explain this in more detail? I'm assuming there is a problem
>> with writing to the TH_LOG_STREAM fd or something?
>
> It's a trick to use the test framework without requiring to be allowed
> to write to an FD (i.e. log stream), but only to exit a code. I use this
> to test a Landlock rule which forbid access to any FS objects (including
> open FD). This could be used for seccomp too.

Okay. For seccomp, we just allow the fd. :P I'm not opposed to it; it
just makes some debugging harder without text details, etc.

-Kees

--=20
Kees Cook
Pixel Security
