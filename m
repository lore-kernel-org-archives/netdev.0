From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v7 08/10] bpf: Add a Landlock sandbox example
Date: Fri, 25 Aug 2017 10:17:58 +0200
Message-ID: <c1245df5-aeef-0406-d4cd-781d65ecf3a7@digikod.net>
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-9-mic@digikod.net>
 <20170824025901.cpppy4nn5xv2ao24@ast-mbp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="CnOi2Bia59nwOIPisNK4aTcM4t2rfO9OW"
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
Return-path: <kernel-hardening-return-9562-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170824025901.cpppy4nn5xv2ao24@ast-mbp>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--CnOi2Bia59nwOIPisNK4aTcM4t2rfO9OW
Content-Type: multipart/mixed; boundary="hcAH3FSfGN3wdBxfR5wTdbTVIut1JDQab";
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
Message-ID: <c1245df5-aeef-0406-d4cd-781d65ecf3a7@digikod.net>
Subject: Re: [PATCH net-next v7 08/10] bpf: Add a Landlock sandbox example
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-9-mic@digikod.net>
 <20170824025901.cpppy4nn5xv2ao24@ast-mbp>
In-Reply-To: <20170824025901.cpppy4nn5xv2ao24@ast-mbp>

--hcAH3FSfGN3wdBxfR5wTdbTVIut1JDQab
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable



On 24/08/2017 04:59, Alexei Starovoitov wrote:
> On Mon, Aug 21, 2017 at 02:09:31AM +0200, Micka=EBl Sala=FCn wrote:
>> Add a basic sandbox tool to create a process isolated from some part o=
f
>> the system. This sandbox create a read-only environment. It is only
>> allowed to write to a character device such as a TTY:
>>
>>   # :> X
>>   # echo $?
>>   0
>>   # ./samples/bpf/landlock1 /bin/sh -i
>>   Launching a new sandboxed process.
>>   # :> Y
>>   cannot create Y: Operation not permitted
>>
>> Signed-off-by: Micka=EBl Sala=FCn <mic@digikod.net>
>=20
> ...
>=20
>> +SEC("landlock1")
>> +static int landlock_fs_prog1(struct landlock_context *ctx)
>> +{
>> +	char fmt_error_mode[] =3D "landlock1: error: get_mode:%lld\n";
>> +	char fmt_error_access[] =3D "landlock1: error: access denied\n";
>> +	long long ret;
>> +
>> +	/*
>> +	 * The argument ctx->arg2 contains bitflags of actions for which the=

>> +	 * rule is run.  The flag LANDLOCK_ACTION_FS_WRITE means that a writ=
e
>> +	 * is requested by one of the userspace processes restricted by this=

>> +	 * rule. The following test allows any actions which does not includ=
e a
>> +	 * write.
>> +	 */
>> +	if (!(ctx->arg2 & LANDLOCK_ACTION_FS_WRITE))
>> +		return 0;
>> +
>> +	/*
>> +	 * The argument ctx->arg1 is a file handle for which the process wan=
t
>> +	 * to access. The function bpf_handle_fs_get_mode() return the mode =
of
>> +	 * a file (e.g. S_IFBLK, S_IFDIR, S_IFREG...). If there is an error,=

>> +	 * for example if the argument is not a file handle, then an
>> +	 * -errno value is returned. Otherwise the caller get the file mode =
as
>> +	 *  with stat(2).
>> +	 */
>> +	ret =3D bpf_handle_fs_get_mode((void *)ctx->arg1);
>> +	if (ret < 0) {
>> +
>> +		/*
>> +		 * The bpf_trace_printk() function enable to write in the
>> +		 * kernel eBPF debug log, accessible through
>> +		 * /sys/kernel/debug/tracing/trace_pipe . To be allowed to call
>> +		 * this function, a Landlock rule must have the
>> +		 * LANDLOCK_SUBTYPE_ABILITY_DEBUG ability, which is only
>> +		 * allowed for CAP_SYS_ADMIN.
>> +		 */
>> +		bpf_trace_printk(fmt_error_mode, sizeof(fmt_error_mode), ret);
>> +		return 1;
>> +	}
>> +
>> +	/*
>> +	 * This check allows the action on the file if it is a directory or =
a
>> +	 * pipe. Otherwise, a message is printed to the eBPF log.
>> +	 */
>> +	if (S_ISCHR(ret) || S_ISFIFO(ret))
>> +		return 0;
>> +	bpf_trace_printk(fmt_error_access, sizeof(fmt_error_access));
>> +	return 1;
>> +}
>> +
>> +/*
>> + * This subtype enable to set the ABI, which ensure that the eBPF con=
text and
>> + * program behavior will be compatible with this Landlock rule.
>> + */
>> +SEC("subtype")
>> +static const union bpf_prog_subtype _subtype =3D {
>> +	.landlock_rule =3D {
>> +		.abi =3D 1,
>> +		.event =3D LANDLOCK_SUBTYPE_EVENT_FS,
>> +		.ability =3D LANDLOCK_SUBTYPE_ABILITY_DEBUG,
>> +	}
>> +};
>=20
> from rule writer perspective can you somehow merge subtype definition
> with the program? It seems they go hand in hand.
> Like section name of the program can be:
> SEC("landlock_rule1/event=3Dfs/ability=3Ddebug")
> static int landlock_fs_prog1(struct landlock_context *ctx)...
> and the loader can parse this string and prepare appropriate
> data structures for the kernel.

Right, I'll try that.


--hcAH3FSfGN3wdBxfR5wTdbTVIut1JDQab--

--CnOi2Bia59nwOIPisNK4aTcM4t2rfO9OW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlmf3TYACgkQIt7+33O9
apUZ1Af+PQHJukWpBulhEXFta88prqo9xcx/Gp9C1R8htzmvbJ1W6iHePaPuAiJI
ZaVjeRoiOIkIc3Bzs8a2MMZpzHWfpqMyq0vFFAlybmGAcB5nSkZvJQClzN/O4G2C
13/LuQi8AH0PNIPphrxZumjyk3vs31KogU2ezxYMsHJghKSkFE1a0CFTai1GBvVM
IjNckIZYYFJ+uH7iJ2vWzC/4G0EtU0sJm9/Sg94egtClOZ8m4RdQtMVWcWRkSyB0
DxkLgKmbcXvCVrwqkFG83qKqd208cskhWmahTdseQhXNGWumDy5qXL1Eo3aKuyHY
Lx1ZZbb4j101qkis/WD3nowWfbJ1gw==
=4A9z
-----END PGP SIGNATURE-----

--CnOi2Bia59nwOIPisNK4aTcM4t2rfO9OW--
