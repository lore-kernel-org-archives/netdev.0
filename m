From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH v5 03/10] bpf: Define handle_fs and add a new helper
 bpf_handle_fs_get_mode()
Date: Wed, 1 Mar 2017 23:20:54 +0100
Message-ID: <3e3d2c43-9d67-2b1e-174a-1656708139f2@digikod.net>
References: <20170222012632.4196-1-mic@digikod.net>
 <20170222012632.4196-4-mic@digikod.net>
 <alpine.LRH.2.20.1703012028110.9253@namei.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="sCqXnFWdagRw80FSU1TSRGigwJKSrhoGH"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
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
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
To: James Morris <jmorris@namei.org>
Return-path: <kernel-hardening-return-6880-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <alpine.LRH.2.20.1703012028110.9253@namei.org>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--sCqXnFWdagRw80FSU1TSRGigwJKSrhoGH
Content-Type: multipart/mixed; boundary="JMpC7mQfwQ8p6g4KisXHXKcl6voV6BVbx";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: James Morris <jmorris@namei.org>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
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
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org
Message-ID: <3e3d2c43-9d67-2b1e-174a-1656708139f2@digikod.net>
Subject: Re: [PATCH v5 03/10] bpf: Define handle_fs and add a new helper
 bpf_handle_fs_get_mode()
References: <20170222012632.4196-1-mic@digikod.net>
 <20170222012632.4196-4-mic@digikod.net>
 <alpine.LRH.2.20.1703012028110.9253@namei.org>
In-Reply-To: <alpine.LRH.2.20.1703012028110.9253@namei.org>

--JMpC7mQfwQ8p6g4KisXHXKcl6voV6BVbx
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 01/03/2017 10:32, James Morris wrote:
> On Wed, 22 Feb 2017, Micka=C3=ABl Sala=C3=BCn wrote:
>=20
>> Add an eBPF function bpf_handle_fs_get_mode(handle_fs) to get the mode=

>> of a an abstract object wrapping either a file, a dentry, a path, or a=
n
>> inode.
>>
>> Changes since v4:
>> * use a file abstraction (handle) to wrap inode, dentry, path and file=

>>   structs
>=20
> Good to see these abstractions.  As discussed at LPC, we need to ensure=
=20
> that we don't couple the Landlock API too closely with the LSM API, as =
the=20
> former is an ABI exposed to userland -- we don't want to lose the abili=
ty=20
> to change LSM internally due to breaking Landlock policies.

Right, it is the case now, especially with the Landlock events.

>=20
>> @@ -82,6 +87,8 @@ enum bpf_arg_type {
>> =20
>>  	ARG_PTR_TO_CTX,		/* pointer to context */
>>  	ARG_ANYTHING,		/* any (initialized) argument is ok */
>> +
>> +	ARG_CONST_PTR_TO_HANDLE_FS,	/* pointer to an abstract FS struct */
>>  };
>=20
> Extraneous whitespace?

It is on purpose, following the same rules as used for this enum.

 Micka=C3=ABl


--JMpC7mQfwQ8p6g4KisXHXKcl6voV6BVbx--

--sCqXnFWdagRw80FSU1TSRGigwJKSrhoGH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAli3SUYACgkQIt7+33O9
apXajgf/RL4nqWHXKhhoSP0o88+vfZZSrLSEdzEQSYZtpJETj3S0/Hh/A92lyVzD
uTZ2Bdo1GXwS7gszX+T0behdkpK1/zJEzL0duAHKlZkt5L6lEgxXxvS1GKoAWayR
mPB9lf7Lmw8I/PakZ3quXZgc+Lr+YtlSXqqT/Ei5T9nltVtH27KXbQvEPmUtNQBU
8CXfwAdOt2L8+wSnzdo0J/dwRrATvQ2eWIth+KmvLO0MG9QN8qrHC4EfwTi/FKP1
Br2HFdtEMT/gXpdGoIwpoEZ2nIhgl6GGrAMzBqVzSBmZdAFs2JcD2J0pnuqIUuag
RO3O8yTKISg9iPG6ZDsFoGf0FEWNiA==
=tR1Z
-----END PGP SIGNATURE-----

--sCqXnFWdagRw80FSU1TSRGigwJKSrhoGH--
