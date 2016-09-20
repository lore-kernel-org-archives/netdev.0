From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
Date: Tue, 20 Sep 2016 19:08:23 +0200
Message-ID: <57E16D07.4050301@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <20160915091902.GA13132@amd>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="qCGnkx6Xsl403aB6RcdWeL44MRl01kuMn"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <kernel-hardening-return-4695-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160915091902.GA13132@amd>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--qCGnkx6Xsl403aB6RcdWeL44MRl01kuMn
Content-Type: multipart/mixed; boundary="2xnahhT8xFxA5OadQCPpMiuTdVSSUewE4";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
 kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
 linux-security-module@vger.kernel.org, netdev@vger.kernel.org
Message-ID: <57E16D07.4050301@digikod.net>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <20160915091902.GA13132@amd>
In-Reply-To: <20160915091902.GA13132@amd>

--2xnahhT8xFxA5OadQCPpMiuTdVSSUewE4
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 15/09/2016 11:19, Pavel Machek wrote:
> Hi!
>=20
>> This series is a proof of concept to fill some missing part of seccomp=
 as the
>> ability to check syscall argument pointers or creating more dynamic se=
curity
>> policies. The goal of this new stackable Linux Security Module (LSM) c=
alled
>> Landlock is to allow any process, including unprivileged ones, to crea=
te
>> powerful security sandboxes comparable to the Seatbelt/XNU Sandbox or =
the
>> OpenBSD Pledge. This kind of sandbox help to mitigate the security imp=
act of
>> bugs or unexpected/malicious behaviors in userland applications.
>>
>> The first RFC [1] was focused on extending seccomp while staying at th=
e syscall
>> level. This brought a working PoC but with some (mitigated) ToCToU rac=
e
>> conditions due to the seccomp ptrace hole (now fixed) and the non-atom=
ic
>> syscall argument evaluation (hence the LSM hooks).
>=20
> Long and nice description follows. Should it go to Documentation/
> somewhere?
>=20
> Because some documentation would be useful...
> 								Pavel

Right, but I was looking for feedback before investing in documentation. =
:)


>=20
>>  include/linux/bpf.h                   |  41 +++++
>>  include/linux/lsm_hooks.h             |   5 +
>>  include/linux/seccomp.h               |  54 ++++++-
>>  include/uapi/asm-generic/errno-base.h |   1 +
>>  include/uapi/linux/bpf.h              | 103 ++++++++++++
>>  include/uapi/linux/seccomp.h          |   2 +
>>  kernel/bpf/arraymap.c                 | 222 +++++++++++++++++++++++++=

>>  kernel/bpf/syscall.c                  |  18 ++-
>>  kernel/bpf/verifier.c                 |  32 +++-
>>  kernel/fork.c                         |  41 ++++-
>>  kernel/seccomp.c                      | 211 +++++++++++++++++++++++-
>>  samples/Makefile                      |   2 +-
>>  samples/landlock/.gitignore           |   1 +
>>  samples/landlock/Makefile             |  16 ++
>>  samples/landlock/sandbox.c            | 295 +++++++++++++++++++++++++=
+++++++++
>>  security/Kconfig                      |   1 +
>>  security/Makefile                     |   2 +
>>  security/landlock/Kconfig             |  19 +++
>>  security/landlock/Makefile            |   3 +
>>  security/landlock/checker_cgroup.c    |  96 +++++++++++
>>  security/landlock/checker_cgroup.h    |  18 +++
>>  security/landlock/checker_fs.c        | 183 +++++++++++++++++++++
>>  security/landlock/checker_fs.h        |  20 +++
>>  security/landlock/lsm.c               | 228 +++++++++++++++++++++++++=
+
>>  security/security.c                   |   1 +
>>  25 files changed, 1592 insertions(+), 23 deletions(-)
>>  create mode 100644 samples/landlock/.gitignore
>>  create mode 100644 samples/landlock/Makefile
>>  create mode 100644 samples/landlock/sandbox.c
>>  create mode 100644 security/landlock/Kconfig
>>  create mode 100644 security/landlock/Makefile
>>  create mode 100644 security/landlock/checker_cgroup.c
>>  create mode 100644 security/landlock/checker_cgroup.h
>>  create mode 100644 security/landlock/checker_fs.c
>>  create mode 100644 security/landlock/checker_fs.h
>>  create mode 100644 security/landlock/lsm.c
>>
>=20


--2xnahhT8xFxA5OadQCPpMiuTdVSSUewE4--

--qCGnkx6Xsl403aB6RcdWeL44MRl01kuMn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX4W0HAAoJECLe/t9zvWqVHacH/ipSB6nL2c5sDoB6jrPNVins
pMccCBGxJnFe1+ha++v5N/zEabUeWe997GcmZOyGosO5b6HmHY1GvK2cH3T1qfiO
3TfLPqPaXdBG28VOhsd7JD3uSgH33rQfQ0tJMHBklbtQbAtFa34II1j+o0gbYx0E
YTRntshXVrRrkpP8RxLehIrn7oSQ3Z9gnvqzBQU/31FLNJBn4uVr7FJrswOio1tU
drVgZxJ0R1y+JAP7CfR31CsR3Sbvj2rRRhMVOOtHrU7twwHNDJjhlC6FHW0z2qYv
WUAfml6fHRvE0ERBEyA06g+SnjrcaJ2uHhsz7Xsx1sUcxGj7L51vAWAQr+R6efw=
=Pc46
-----END PGP SIGNATURE-----

--qCGnkx6Xsl403aB6RcdWeL44MRl01kuMn--
