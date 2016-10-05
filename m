From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 16/22] bpf/cgroup,landlock: Handle Landlock hooks per
 cgroup
Date: Wed, 5 Oct 2016 22:58:22 +0200
Message-ID: <57F5696E.6020502@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-17-mic@digikod.net>
 <CAGXu5jJ-Heb0nnLygYo0xHaJKSrQM5RSVRNYN2NnYddwGHtWkA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="PU4dOwH7adTp8FnUaRCJCv8PWwpiWip1P"
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
        linux-security-module <linux-s
To: Kees Cook <keescook@chromium.org>
Return-path: <kernel-hardening-return-4806-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5jJ-Heb0nnLygYo0xHaJKSrQM5RSVRNYN2NnYddwGHtWkA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--PU4dOwH7adTp8FnUaRCJCv8PWwpiWip1P
Content-Type: multipart/mixed; boundary="o1thcT81eHvjRTKtdFoD4PdWGjgXkxD2n";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Paul Moore <pmoore@redhat.com>,
 Sargun Dhillon <sargun@sargun.me>, "Serge E . Hallyn" <serge@hallyn.com>,
 Tejun Heo <tj@kernel.org>, Will Drewry <wad@chromium.org>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 linux-security-module <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>,
 Cgroups <cgroups@vger.kernel.org>
Message-ID: <57F5696E.6020502@digikod.net>
Subject: Re: [RFC v3 16/22] bpf/cgroup,landlock: Handle Landlock hooks per
 cgroup
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-17-mic@digikod.net>
 <CAGXu5jJ-Heb0nnLygYo0xHaJKSrQM5RSVRNYN2NnYddwGHtWkA@mail.gmail.com>
In-Reply-To: <CAGXu5jJ-Heb0nnLygYo0xHaJKSrQM5RSVRNYN2NnYddwGHtWkA@mail.gmail.com>

--o1thcT81eHvjRTKtdFoD4PdWGjgXkxD2n
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On 04/10/2016 01:43, Kees Cook wrote:
> On Wed, Sep 14, 2016 at 12:24 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod=
=2Enet> wrote:
>> This allows to add new eBPF programs to Landlock hooks dedicated to a
>> cgroup thanks to the BPF_PROG_ATTACH command. Like for socket eBPF
>> programs, the Landlock hooks attached to a cgroup are propagated to th=
e
>> nested cgroups. However, when a new Landlock program is attached to on=
e
>> of this nested cgroup, this cgroup hierarchy fork the Landlock hooks.
>> This design is simple and match the current CONFIG_BPF_CGROUP
>> inheritance. The difference lie in the fact that Landlock programs can=

>> only be stacked but not removed. This match the append-only seccomp
>> behavior. Userland is free to handle Landlock hooks attached to a cgro=
up
>> in more complicated ways (e.g. continuous inheritance), but care shoul=
d
>> be taken to properly handle error cases (e.g. memory allocation errors=
).
>>
>> Changes since v2:
>> * new design based on BPF_PROG_ATTACH (suggested by Alexei Starovoitov=
)
>>
>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>> Cc: Alexei Starovoitov <ast@kernel.org>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: Daniel Mack <daniel@zonque.org>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Kees Cook <keescook@chromium.org>
>> Cc: Tejun Heo <tj@kernel.org>
>> Link: https://lkml.kernel.org/r/20160826021432.GA8291@ast-mbp.thefaceb=
ook.com
>> Link: https://lkml.kernel.org/r/20160827204307.GA43714@ast-mbp.theface=
book.com
>> ---
>>  include/linux/bpf-cgroup.h  |  7 +++++++
>>  include/linux/cgroup-defs.h |  2 ++
>>  include/linux/landlock.h    |  9 +++++++++
>>  include/uapi/linux/bpf.h    |  1 +
>>  kernel/bpf/cgroup.c         | 33 ++++++++++++++++++++++++++++++---
>>  kernel/bpf/syscall.c        | 11 +++++++++++
>>  security/landlock/lsm.c     | 40 ++++++++++++++++++++++++++++++++++++=
+++-
>>  security/landlock/manager.c | 32 ++++++++++++++++++++++++++++++++
>>  8 files changed, 131 insertions(+), 4 deletions(-)
>>
>> [...]
>> diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
>> index 7b75fa692617..1c18fe46958a 100644
>> --- a/kernel/bpf/cgroup.c
>> +++ b/kernel/bpf/cgroup.c
>> @@ -15,6 +15,7 @@
>>  #include <linux/bpf.h>
>>  #include <linux/bpf-cgroup.h>
>>  #include <net/sock.h>
>> +#include <linux/landlock.h>
>>
>>  DEFINE_STATIC_KEY_FALSE(cgroup_bpf_enabled_key);
>>  EXPORT_SYMBOL(cgroup_bpf_enabled_key);
>> @@ -31,7 +32,15 @@ void cgroup_bpf_put(struct cgroup *cgrp)
>>                 union bpf_object pinned =3D cgrp->bpf.pinned[type];
>>
>>                 if (pinned.prog) {
>> -                       bpf_prog_put(pinned.prog);
>> +                       switch (type) {
>> +                       case BPF_CGROUP_LANDLOCK:
>> +#ifdef CONFIG_SECURITY_LANDLOCK
>> +                               put_landlock_hooks(pinned.hooks);
>> +                               break;
>> +#endif /* CONFIG_SECURITY_LANDLOCK */
>> +                       default:
>> +                               bpf_prog_put(pinned.prog);
>> +                       }
>>                         static_branch_dec(&cgroup_bpf_enabled_key);
>>                 }
>>         }
>=20
> I get creeped out by type-controlled unions of pointers. :P I don't
> have a suggestion to improve this, but I don't like seeing a pointer
> type managed separately from the pointer itself as it tends to bypass
> a lot of both static and dynamic checking. A union is better than a
> cast of void *, but it still worries me. :)

This is not fully satisfactory for me neither but the other approach is
to use two distinct struct fields instead of a union.
Do you prefer if there is a "type" field in the "pinned" struct to
select the union?

 Micka=C3=ABl


--o1thcT81eHvjRTKtdFoD4PdWGjgXkxD2n--

--PU4dOwH7adTp8FnUaRCJCv8PWwpiWip1P
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX9WluAAoJECLe/t9zvWqV3zIH/i51f0g8+ns1zVEmSWjf5cuj
1zB5wkUhqL4gOtNr6lNUmcl/rc9v/llBVhhmE+iOKpeuCngQYpwtM8znPiDpTfcr
NrwpP1/Sw0Vck7sM17WCFY/gqopvVQCEPBo+eAWOOxTG5FUCSPHBHphp+PATZJDq
qy3G1ToFb01ug6SijydK2t/FIDak+dY29r8i30XCrxvhcpMvFk1BIKudIN7Z30VG
cDvJbtb5exRik3ifvjPavNdXlgp3nEpt129B48AJniW5CUZJRx90Mbhfk1uLyq8l
oL7k1Rlpmg8k4HoYSAEjo5uLfpMhtwudb0B/TLx9mFCrMHIIhvIzi/mEnXPXbvY=
=TqHL
-----END PGP SIGNATURE-----

--PU4dOwH7adTp8FnUaRCJCv8PWwpiWip1P--
