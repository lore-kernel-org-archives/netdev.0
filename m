From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 07/22] landlock: Handle file comparisons
Date: Thu, 15 Sep 2016 01:02:22 +0200
Message-ID: <57D9D6FE.4090708@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-8-mic@digikod.net>
 <20160914210649.GA57174@ast-mbp.thefacebook.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="SXCA75wmoV53MndTlLhho2biccMIEfU2O"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
        linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
        netdev@vger.ker
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <kernel-hardening-return-4641-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914210649.GA57174@ast-mbp.thefacebook.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SXCA75wmoV53MndTlLhho2biccMIEfU2O
Content-Type: multipart/mixed; boundary="j2PLmPOuAn4XcwbcIrcIHwOd5xvLH6AUk";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
 Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, cgroups@vger.kernel.org
Message-ID: <57D9D6FE.4090708@digikod.net>
Subject: Re: [RFC v3 07/22] landlock: Handle file comparisons
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-8-mic@digikod.net>
 <20160914210649.GA57174@ast-mbp.thefacebook.com>
In-Reply-To: <20160914210649.GA57174@ast-mbp.thefacebook.com>

--j2PLmPOuAn4XcwbcIrcIHwOd5xvLH6AUk
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable



On 14/09/2016 23:06, Alexei Starovoitov wrote:
> On Wed, Sep 14, 2016 at 09:24:00AM +0200, Micka=EBl Sala=FCn wrote:
>> Add eBPF functions to compare file system access with a Landlock file
>> system handle:
>> * bpf_landlock_cmp_fs_prop_with_struct_file(prop, map, map_op, file)
>>   This function allows to compare the dentry, inode, device or mount
>>   point of the currently accessed file, with a reference handle.
>> * bpf_landlock_cmp_fs_beneath_with_struct_file(opt, map, map_op, file)=

>>   This function allows an eBPF program to check if the current accesse=
d
>>   file is the same or in the hierarchy of a reference handle.
>>
>> The goal of file system handle is to abstract kernel objects such as a=

>> struct file or a struct inode. Userland can create this kind of handle=

>> thanks to the BPF_MAP_UPDATE_ELEM command. The element is a struct
>> landlock_handle containing the handle type (e.g.
>> BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) and a file descriptor. This could
>> also be any descriptions able to match a struct file or a struct inode=

>> (e.g. path or glob string).
>>
>> Changes since v2:
>> * add MNT_INTERNAL check to only add file handle from user-visible FS
>>   (e.g. no anonymous inode)
>> * replace struct file* with struct path* in map_landlock_handle
>> * add BPF protos
>> * fix bpf_landlock_cmp_fs_prop_with_struct_file()
>>
>> Signed-off-by: Micka=EBl Sala=FCn <mic@digikod.net>
>> Cc: Alexei Starovoitov <ast@kernel.org>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: James Morris <james.l.morris@oracle.com>
>> Cc: Kees Cook <keescook@chromium.org>
>> Cc: Serge E. Hallyn <serge@hallyn.com>
>> Link: https://lkml.kernel.org/r/CALCETrWwTiz3kZTkEgOW24-DvhQq6LftwEXh7=
7FD2G5o71yD7g@mail.gmail.com
>=20
> thanks for keeping the links to the previous discussion.
> Long term it should help, though I worry we already at the point
> where there are too many outstanding issues to resolve before we
> can proceed with reasonable code review.
>=20
>> +/*
>> + * bpf_landlock_cmp_fs_prop_with_struct_file
>> + *
>> + * Cf. include/uapi/linux/bpf.h
>> + */
>> +static inline u64 bpf_landlock_cmp_fs_prop_with_struct_file(u64 r1_pr=
operty,
>> +		u64 r2_map, u64 r3_map_op, u64 r4_file, u64 r5)
>> +{
>> +	u8 property =3D (u8) r1_property;
>> +	struct bpf_map *map =3D (struct bpf_map *) (unsigned long) r2_map;
>> +	enum bpf_map_array_op map_op =3D r3_map_op;
>> +	struct file *file =3D (struct file *) (unsigned long) r4_file;
>=20
> please use just added BPF_CALL_ macros. They will help readability of t=
he above.
>=20
>> +	struct bpf_array *array =3D container_of(map, struct bpf_array, map)=
;
>> +	struct path *p1, *p2;
>> +	struct map_landlock_handle *handle;
>> +	int i;
>> +
>> +	/* ARG_CONST_PTR_TO_LANDLOCK_HANDLE_FS is an arraymap */
>> +	if (unlikely(!map)) {
>> +		WARN_ON(1);
>> +		return -EFAULT;
>> +	}
>> +	if (unlikely(!file))
>> +		return -ENOENT;
>> +	if (unlikely((property | _LANDLOCK_FLAG_FS_MASK) !=3D _LANDLOCK_FLAG=
_FS_MASK))
>> +		return -EINVAL;
>> +
>> +	/* for now, only handle OP_OR */
>> +	switch (map_op) {
>> +	case BPF_MAP_ARRAY_OP_OR:
>> +		break;
>> +	case BPF_MAP_ARRAY_OP_UNSPEC:
>> +	case BPF_MAP_ARRAY_OP_AND:
>> +	case BPF_MAP_ARRAY_OP_XOR:
>> +	default:
>> +		return -EINVAL;
>> +	}
>> +	p2 =3D &file->f_path;
>> +
>> +	synchronize_rcu();
>=20
> that is completely broken.
> bpf programs are executing under rcu_lock.
> please enable CONFIG_PROVE_RCU and retest everything.

Thanks for the tip. I will fix this.

>=20
> I would suggest for the next RFC to do minimal 7 patches up to this poi=
nt
> with simple example that demonstrates the use case.
> I would avoid all unpriv stuff and all of seccomp for the next RFC as w=
ell,
> otherwise I don't think we can realistically make forward progress, sin=
ce
> there are too many issues raised in the subsequent patches.

I hope we will find a common agreement about seccomp vs cgroup=85 I think=

both approaches have their advantages, can be complementary and nicely
combined.

Unprivileged sandboxing is the main goal of Landlock. This should not be
a problem, even for privileged features, thanks to the new subtype/access=
=2E

>=20
> The common part that is mergeable is prog's subtype extension to
> the verifier that can be used for better tracing and is the common
> piece of infra needed for both landlock and checmate LSMs
> (which must be one LSM anyway)

Agreed. With this RFC, the Checmate features (i.e. network helpers)
should be able to sit on top of Landlock.


--j2PLmPOuAn4XcwbcIrcIHwOd5xvLH6AUk--

--SXCA75wmoV53MndTlLhho2biccMIEfU2O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX2db+AAoJECLe/t9zvWqVMj8H/Att7euvKAikVzWHFuxcx6q1
g11uip8q9HMl+uwU8H+enEBMq+OhTvrVBVK3SSAPs4BInYvmM1ukh31nLZLbB4pt
aRHF+cM0dA1byXni0LyqmLFiztzn3nes4E9BrwfiIJnfJspwuyLRfZH/vk5LLabM
Ln45Dn1yJE+XAoQHrEPAjslSs+ydrG/tI3WN/pXcxT61pfvIXRaGPA0zQCgwbEPj
AbmIj8XATRFq259aZOVJf0+IamAjU7HNN7qjbEbEsrCaXNyzQ4NByuyPyKLNgmUu
a7jhbM5K0D15DdjPiHRtWdeVqODP9joDPD2vGtm8ikkuE7MJ95FSVkQAqhO3G9k=
=ZR5b
-----END PGP SIGNATURE-----

--SXCA75wmoV53MndTlLhho2biccMIEfU2O--
