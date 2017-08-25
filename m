From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v7 05/10] landlock: Add LSM hooks related to
 filesystem
Date: Fri, 25 Aug 2017 10:16:39 +0200
Message-ID: <22d09137-7212-5803-af64-0964fad875c7@digikod.net>
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-6-mic@digikod.net>
 <20170824025030.sxl2hkpcbzipb47y@ast-mbp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="s04RxWkgoJ7sRIkvbQdeJm2sAVwVhjKNQ"
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
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <kernel-hardening-return-9561-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170824025030.sxl2hkpcbzipb47y@ast-mbp>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--s04RxWkgoJ7sRIkvbQdeJm2sAVwVhjKNQ
Content-Type: multipart/mixed; boundary="LLTwOboxMdBfWGKTTV3lgbHVGUtSCXOHC";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
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
Message-ID: <22d09137-7212-5803-af64-0964fad875c7@digikod.net>
Subject: Re: [PATCH net-next v7 05/10] landlock: Add LSM hooks related to
 filesystem
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-6-mic@digikod.net>
 <20170824025030.sxl2hkpcbzipb47y@ast-mbp>
In-Reply-To: <20170824025030.sxl2hkpcbzipb47y@ast-mbp>

--LLTwOboxMdBfWGKTTV3lgbHVGUtSCXOHC
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 24/08/2017 04:50, Alexei Starovoitov wrote:
> On Mon, Aug 21, 2017 at 02:09:28AM +0200, Micka=EBl Sala=FCn wrote:
>> Handle 33 filesystem-related LSM hooks for the Landlock filesystem
>> event: LANDLOCK_SUBTYPE_EVENT_FS.
>>
>> A Landlock event wrap LSM hooks for similar kernel object types (e.g.
>> struct file, struct path...). Multiple LSM hooks can trigger the same
>> Landlock event.
>>
>> Landlock handle nine coarse-grained actions: read, write, execute, new=
,
>> get, remove, ioctl, lock and fcntl. Each of them abstract LSM hook
>> access control in a way that can be extended in the future.
>>
>> The Landlock LSM hook registration is done after other LSM to only run=

>> actions from user-space, via eBPF programs, if the access was granted =
by
>> major (privileged) LSMs.
>>
>> Signed-off-by: Micka=EBl Sala=FCn <mic@digikod.net>
>=20
> ...
>=20
>> +/* WRAP_ARG_SB */
>> +#define WRAP_ARG_SB_TYPE	WRAP_TYPE_FS
>> +#define WRAP_ARG_SB_DEC(arg)					\
>> +	EXPAND_C(WRAP_TYPE_FS) wrap_##arg =3D			\
>> +	{ .type =3D BPF_HANDLE_FS_TYPE_DENTRY, .dentry =3D arg->s_root };
>> +#define WRAP_ARG_SB_VAL(arg)	((uintptr_t)&wrap_##arg)
>> +#define WRAP_ARG_SB_OK(arg)	(arg && arg->s_root)
> ...
>=20
>> +HOOK_NEW_FS(sb_remount, 2,
>> +	struct super_block *, sb,
>> +	void *, data,
>> +	WRAP_ARG_SB, sb,
>> +	WRAP_ARG_RAW, LANDLOCK_ACTION_FS_WRITE
>> +);
>=20
> this looks wrong. casting super_block to dentry?

This is called when remounting a block device. The WRAP_ARG_SB take the
sb->s_root as a dentry, it is not a cast. What do you expect from this ho=
ok?

>=20
>> +/* a directory inode contains only one dentry */
>> +HOOK_NEW_FS(inode_create, 3,
>> +	struct inode *, dir,
>> +	struct dentry *, dentry,
>> +	umode_t, mode,
>> +	WRAP_ARG_INODE, dir,
>> +	WRAP_ARG_RAW, LANDLOCK_ACTION_FS_WRITE
>> +);
>=20
> more general question: why you're not wrapping all useful
> arguments? Like in the above dentry can be acted upon
> by the landlock rule and it's readily available...

The context used for the FS event must have the exact same types for all
calls. This event is meant to be generic but we can add more specific
ones if needed, like I do with FS_IOCTL.

The idea is to enable people to write simple rules, while being able to
write fine grain rules for special cases (e.g. IOCTL) if needed.

>=20
> The limitation of only 2 args looks odd.
> Is it a hard limitation ? how hard to extend?

It's not a hard limit at all. Actually, the FS_FNCTL event should have
three arguments (I'll add them in the next series): FS handle, FCNTL
command and FCNTL argument. I made sure that it's really easy to add
more arguments to the context of an event.


--LLTwOboxMdBfWGKTTV3lgbHVGUtSCXOHC--

--s04RxWkgoJ7sRIkvbQdeJm2sAVwVhjKNQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlmf3OgACgkQIt7+33O9
apWYEwf+LLl/uJngJV/UmbXlLh/xSWLS91mygv8YmLO64XSOVZjMSvqsX6NMiDgK
Ciqqj0Ps/VvD7YHFR1Zpul0ND6mPdodh4Wp4kt5OPX2NRTqGLafp/TQciszkzFqp
Iv4nvbQpN9kgPecsqlgrVc6kUQfa+S/5Day5ZxLJs7qGtZzIxZbUYOHJjhB41iPS
X1Xa6Vii9iPzu7eX7hxe+O85SHT+xydtbcUR1u9vQB1tSv7AgnshvdRy3LSxC9Yf
FjmK6DxQ/KQx0C/lZx5kYz/7NST5JXgR8PHS6diW0DBtbFt+DXDtIEierQD6H7Oo
s+9/9QEpMeFn9WeWqvQ8+CVfNoiG+w==
=bU84
-----END PGP SIGNATURE-----

--s04RxWkgoJ7sRIkvbQdeJm2sAVwVhjKNQ--
