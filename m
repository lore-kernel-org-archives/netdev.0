From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v6 06/11] seccomp,landlock:
 Handle Landlock events per process hierarchy
Date: Fri, 31 Mar 2017 23:15:37 +0200
Message-ID: <b0662712-53f4-1293-aa61-f0455301d7cc@digikod.net>
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-7-mic@digikod.net>
 <CAEiveUcp6xpUW764zupy8ekttnQGaonXFn-JEFg7nhXUKzenDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="s4vekTFDgBRs0jPPhSIJAk0Wswo40ibIX"
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale
 <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.org>, Thomas G
To: Djalal Harouni <tixxdz@gmail.com>
Return-path: <kernel-hardening-return-7216-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAEiveUcp6xpUW764zupy8ekttnQGaonXFn-JEFg7nhXUKzenDg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--s4vekTFDgBRs0jPPhSIJAk0Wswo40ibIX
Content-Type: multipart/mixed; boundary="hK6NeB2cm4U1IrlaGQfJmjPpWw4v1dsn3";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Djalal Harouni <tixxdz@gmail.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>, Andy Lutomirski <luto@amacapital.net>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, David Drysdale
 <drysdale@google.com>, "David S . Miller" <davem@davemloft.net>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
 Jonathan Corbet <corbet@lwn.net>, Matthew Garrett <mjg59@srcf.ucam.org>,
 Michael Kerrisk <mtk.manpages@gmail.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <paul@paul-moore.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
 Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
 Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
 Linux API <linux-api@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>, netdev@vger.kernel.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <b0662712-53f4-1293-aa61-f0455301d7cc@digikod.net>
Subject: Re: [kernel-hardening] [PATCH net-next v6 06/11] seccomp,landlock:
 Handle Landlock events per process hierarchy
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-7-mic@digikod.net>
 <CAEiveUcp6xpUW764zupy8ekttnQGaonXFn-JEFg7nhXUKzenDg@mail.gmail.com>
In-Reply-To: <CAEiveUcp6xpUW764zupy8ekttnQGaonXFn-JEFg7nhXUKzenDg@mail.gmail.com>

--hK6NeB2cm4U1IrlaGQfJmjPpWw4v1dsn3
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On 29/03/2017 12:35, Djalal Harouni wrote:
> On Wed, Mar 29, 2017 at 1:46 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:

>> @@ -25,6 +30,9 @@ struct seccomp_filter;
>>  struct seccomp {
>>         int mode;
>>         struct seccomp_filter *filter;
>> +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOC=
K)
>> +       struct landlock_events *landlock_events;
>> +#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
>>  };
>=20
> Sorry if this was discussed before, but since this is mean to be a
> stackable LSM, I'm wondering if later you could move the events from
> seccomp, and go with a security_task_alloc() model [1] ?
>=20
> Thanks!
>=20
> [1] http://kernsec.org/pipermail/linux-security-module-archive/2017-Mar=
ch/000184.html
>=20

Landlock use the seccomp syscall to attach a rule to a process and using
struct seccomp to store this rule make sense. There is currently no way
to store multiple task->security, which is needed for a stackable LSM
like Landlock, but we could move the events there if needed in the future=
=2E

 Micka=C3=ABl


--hK6NeB2cm4U1IrlaGQfJmjPpWw4v1dsn3--

--s4vekTFDgBRs0jPPhSIJAk0Wswo40ibIX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAljexvkACgkQIt7+33O9
apXTugf9G00LkzuQTWtDhb6UG/2wEh7TKvzg2eXpVR2P92ZhHCXJmvGe1eQuk52c
XJbx05s9G1M2kmn3OalXVoHEPAsg0r12Ig/XAxg6ZiGYO321FbPOHV9rx/eOYqeR
TPyFvMfwQIbzO2CGV7sULdk+GCVYharK9n6glOrqJQ1MSF5/vu8Jz1WsGquaOGg1
n+dJ1LQTxwUiIGrT4P+PakOjC2GRzCE99mKUN15iEI91a6AzlXh+2ttYdu8cg7Ie
pSYYEnEkT2B6hR+whX52iIGc0hGxfXxui0k3iA6RPcKaKc8e+WGyyrwX/NxSIvDU
dJuM4TVeAEauG7q8o8apbEaqc5hiXw==
=wefm
-----END PGP SIGNATURE-----

--s4vekTFDgBRs0jPPhSIJAk0Wswo40ibIX--
