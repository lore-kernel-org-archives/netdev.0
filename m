From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
Date: Sat, 27 Aug 2016 21:35:14 +0200
Message-ID: <57C1EB72.2050703@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
 <57C19E6E.6040908@digikod.net>
 <20160827180642.GA38754@ast-mbp.thefacebook.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="G3g8KoHC06kMmFplvftMQOTxCWIrMcHf0"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Daniel Borkmann
 <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        "David S . Miller" <davem@davemloft.net>,
        Kees Cook <keescook@chromium.org>, Sargun Dhillon <sargun@sargun.me>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <kernel-hardening-return-4492-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160827180642.GA38754@ast-mbp.thefacebook.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--G3g8KoHC06kMmFplvftMQOTxCWIrMcHf0
Content-Type: multipart/mixed; boundary="JUgEdnpOjxoOXANkuK2oNg02t617h3pFs"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Daniel Borkmann
 <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 "David S . Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>,
 Sargun Dhillon <sargun@sargun.me>, kernel-hardening@lists.openwall.com,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org
Message-ID: <57C1EB72.2050703@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
 <57C19E6E.6040908@digikod.net>
 <20160827180642.GA38754@ast-mbp.thefacebook.com>
In-Reply-To: <20160827180642.GA38754@ast-mbp.thefacebook.com>

--JUgEdnpOjxoOXANkuK2oNg02t617h3pFs
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 27/08/2016 20:06, Alexei Starovoitov wrote:
> On Sat, Aug 27, 2016 at 04:06:38PM +0200, Micka=EBl Sala=FCn wrote:
>>
>> On 27/08/2016 01:05, Alexei Starovoitov wrote:
>>> On Fri, Aug 26, 2016 at 05:10:40PM +0200, Micka=EBl Sala=FCn wrote:
>>>>
>>>>>
>>>>> - I don't think such 'for' loop can scale. The solution needs to wo=
rk
>>>>> with thousands of containers and thousands of cgroups.
>>>>> In the patch 06/10 the proposal is to use 'current' as holder of
>>>>> the programs:
>>>>> +   for (prog =3D current->seccomp.landlock_prog;
>>>>> +                   prog; prog =3D prog->prev) {
>>>>> +           if (prog->filter =3D=3D landlock_ret->filter) {
>>>>> +                   cur_ret =3D BPF_PROG_RUN(prog->prog, (void *)&c=
tx);
>>>>> +                   break;
>>>>> +           }
>>>>> +   }
>>>>> imo that's the root of scalability issue.
>>>>> I think to be able to scale the bpf programs have to be attached to=

>>>>> cgroups instead of tasks.
>>>>> That would be very different api. seccomp doesn't need to be touche=
d.
>>>>> But that is the only way I see to be able to scale.
>>>>
>>>> Landlock is inspired from seccomp which also use a BPF program per
>>>> thread. For seccomp, each BPF programs are executed for each syscall=
=2E
>>>> For Landlock, some BPF programs are executed for some LSM hooks. I d=
on't
>>>> see why it is a scale issue for Landlock comparing to seccomp. I als=
o
>>>> don't see why storing the BPF program list pointer in the cgroup str=
uct
>>>> instead of the task struct change a lot here. The BPF programs execu=
tion
>>>> will be the same anyway (for each LSM hook). Kees should probably ha=
ve a
>>>> better opinion on this.
>>>
>>> seccomp has its own issues and copying them doesn't make this lsm any=
 better.
>>> Like seccomp bpf programs are all gigantic switch statement that look=
s
>>> for interesting syscall numbers. All syscalls of a task are paying
>>> non-trivial seccomp penalty due to such design. If bpf was attached p=
er
>>> syscall it would have been much cheaper. Of course doing it this way
>>> for seccomp is not easy, but for lsm such facility is already there.
>>> Blank call of a single bpf prog for all lsm hooks is unnecessary
>>> overhead that can and should be avoided.
>>
>> It's probably a misunderstanding. Contrary to seccomp which run all th=
e
>> thread's BPF programs for any syscall, Landlock only run eBPF programs=

>> for the triggered LSM hooks, if their type match. Indeed, thanks to th=
e
>> multiple eBPF program types and contrary to seccomp, Landlock only run=

>> an eBPF program when needed. Landlock will have almost no performance
>> overhead if the syscalls do not trigger the watched LSM hooks for the
>> current process.
>=20
> that's not what I see in the patch 06/10:
> all lsm_hooks in 'static struct security_hook_list landlock_hooks'
> (which eventually means all lsm hooks) will call
> static inline int landlock_hook_##NAME
> which will call landlock_run_prog()
> which does:
> + for (landlock_ret =3D current->seccomp.landlock_ret;
> +      landlock_ret; landlock_ret =3D landlock_ret->prev) {
> +    if (landlock_ret->triggered) {
> +       ctx.cookie =3D landlock_ret->cookie;
> +       for (prog =3D current->seccomp.landlock_prog;
> +            prog; prog =3D prog->prev) {
> +               if (prog->filter =3D=3D landlock_ret->filter) {
> +                       cur_ret =3D BPF_PROG_RUN(prog->prog, (void *)&c=
tx);
> +                       break;
> +               }
> +       }
>=20
> that is unacceptable overhead and not a scalable design.
> It kinda works for 3 lsm_hooks as in patch 6, but doesn't scale
> as soon as more lsm hooks are added.

Good catch! I forgot to check the program (sub)type in the loop to only
run the needed programs for the current hook. I will fix this.


>=20
>> As said above, Landlock will not run an eBPF programs when not strictl=
y
>> needed. Attaching to a cgroup will have the same performance impact as=

>> attaching to a process hierarchy.
>=20
> Having a prog per cgroup per lsm_hook is the only scalable way I
> could come up with. If you see another way, please propose.
> current->seccomp.landlock_prog is not the answer.

Hum, I don't see the difference from a performance point of view between
a cgroup-based or a process hierarchy-based system.

Maybe a better option should be to use an array of pointers with N
entries, one for each supported hook, instead of a unique pointer list?

Anyway, being able to attach an LSM hook program to a cgroup thanks to
the new BPF_PROG_ATTACH seems a good idea (while keeping the possibility
to use a process hierarchy). The downside will be to handle an LSM hook
program which is not triggered by a seccomp-filter, but this should be
needed anyway to handle interruptions.


--JUgEdnpOjxoOXANkuK2oNg02t617h3pFs--

--G3g8KoHC06kMmFplvftMQOTxCWIrMcHf0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXwetyAAoJECLe/t9zvWqVFqcH/1IbW2yp5+eSaQf+1RrBgCbK
kAh9PrSG8Sz6JANiOUk3FNJQIGHNAwnFVjs+RwRWb2X7DzlCm6LHI19up1FNIGfV
HFt5Q+/Wxil3FKtEb1NRsErxJ96hjnh4rIb11/yPQ8uzwrqR3c3rmedQKE9ejob0
H3O6sudJkAvEdj2Z2QsUrSqEmrDQz652U1QFl1Qlwz+goIq2Ds6/MRUYIV8cVXe1
59fh9StFnUL4lGeRfcXAo1PTG985/oHZI5PbN+IBSPGphBxmjwPQkCWFziZ0df64
MYzsc2R4edvetJM8PL9hVFguzaH0No7KVlJheywOIVj8puWqbVlzBFXwKOLv82o=
=Tysc
-----END PGP SIGNATURE-----

--G3g8KoHC06kMmFplvftMQOTxCWIrMcHf0--
