From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v4 00/18] Landlock LSM: Unprivileged sandboxing
Date: Wed, 26 Oct 2016 19:24:31 +0200
Message-ID: <5810E6CF.1080406@digikod.net>
References: <20161026065654.19166-1-mic@digikod.net>
 <20161026145207.GM3334@pc.thejh.net> <5810E04D.9020300@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Oe20C1XpLU2VVbrSVHltQJH8iHbH2u3aC"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Daniel Borkmann
 <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        cgroups@vger.kernel.org
To: Jann Horn <jann@thejh.net>
Return-path: <kernel-hardening-return-5049-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <5810E04D.9020300@digikod.net>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Oe20C1XpLU2VVbrSVHltQJH8iHbH2u3aC
Content-Type: multipart/mixed; boundary="b3xwEvxfADrG84CVmJpSWaJffwLtlfomS";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Jann Horn <jann@thejh.net>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Daniel Borkmann
 <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
 Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
 kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
 linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
 cgroups@vger.kernel.org
Message-ID: <5810E6CF.1080406@digikod.net>
Subject: Re: [RFC v4 00/18] Landlock LSM: Unprivileged sandboxing
References: <20161026065654.19166-1-mic@digikod.net>
 <20161026145207.GM3334@pc.thejh.net> <5810E04D.9020300@digikod.net>
In-Reply-To: <5810E04D.9020300@digikod.net>

--b3xwEvxfADrG84CVmJpSWaJffwLtlfomS
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 26/10/2016 18:56, Micka=EBl Sala=FCn wrote:
>=20
> On 26/10/2016 16:52, Jann Horn wrote:
>> On Wed, Oct 26, 2016 at 08:56:36AM +0200, Micka=EBl Sala=FCn wrote:
>>> The loaded Landlock eBPF programs can be triggered by a seccomp filte=
r
>>> returning RET_LANDLOCK. In addition, a cookie (16-bit value) can be p=
assed from
>>> a seccomp filter to eBPF programs. This allow flexible security polic=
ies
>>> between seccomp and Landlock.
>>
>> Is this still up to date, or was that removed in v3?
>>
>=20
> I forgot to remove this part. In this v4 series, as describe in the
> (small) patch 11/18, a Landlock rule cannot be triggered by a seccomp
> filter. So there is no more RET_LANDLOCK nor cookie.
>=20

Here is an up-to-date version:

# Use case scenario

First, a process needs to create a new dedicated eBPF map containing hand=
les.
This handles are references to system resources (e.g. file or directory).=
 They
are grouped in one or multiple maps to be efficiently managed and checked=
 in
batches. This kind of map can be passed to Landlock eBPF functions to com=
pare,
for example, with a file access request.

First, a task need to create or receive a Landlock rule. This rule is a
dedicated eBPF program tied to one of the Landlock hooks, which are a sub=
set of
LSM hooks. Once loaded, a Landlock rule can be enforced through the secco=
mp(2)
syscall for the current thread and its (future) children, like a seccomp
filter.

Another way to enforce a Landlock security policy is to attach Landlock r=
ules
to a cgroup. All the processes in this cgroup will then be subject to thi=
s
policy.

A triggered Landlock eBPF program can allow or deny an access, according =
to
its subtype (i.e. LSM hook), thanks to errno return values.



--b3xwEvxfADrG84CVmJpSWaJffwLtlfomS--

--Oe20C1XpLU2VVbrSVHltQJH8iHbH2u3aC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJYEObPAAoJECLe/t9zvWqVpIgH/jvnYyJy2FhNeNF0K4fH76VU
hBu8OW2pOFgqMGe0b4qWpOmms8mym/hsUYmM3+ElCWtGputo0EchqRyF8tIGZXX0
eIRK8PAAILJOYuAP+sF+y6kt6gg7gDakJFTQlX392BymLiMmB8Iz+/wAWTJ+lhiG
4PATNIjZHJnxSWqeWyRu5jGvMmhMb9xLBJWu67xbr8DPwC5VhdXJTZnMUr0urV27
5q9ZrEOR7M2rOS3KBW1FfcfDc9SJ+LyOhoPGBKEPWu/+uOaybhzLR6VDiPvBItGH
NLeEqDxpwJsZgHwpHi7jukbApId5NIhXKG9g0K1BG/2DtlOkPOkZyAcrZziQvjg=
=JnCs
-----END PGP SIGNATURE-----

--Oe20C1XpLU2VVbrSVHltQJH8iHbH2u3aC--
