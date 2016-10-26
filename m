From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v4 03/18] bpf,landlock: Add a new
 arraymap type to deal with (Landlock) handles
Date: Wed, 26 Oct 2016 22:03:09 +0200
Message-ID: <58110BFD.5090005@digikod.net>
References: <20161026065654.19166-1-mic@digikod.net>
 <20161026065654.19166-4-mic@digikod.net> <20161026190147.GN3334@pc.thejh.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="eanIdfAB2UJqb9odiraaGVVLRF65XF93a"
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
Return-path: <kernel-hardening-return-5055-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161026190147.GN3334@pc.thejh.net>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--eanIdfAB2UJqb9odiraaGVVLRF65XF93a
Content-Type: multipart/mixed; boundary="DidUHIrNlB58OejuDToDi6kWuLie2SJ5l";
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
Message-ID: <58110BFD.5090005@digikod.net>
Subject: Re: [kernel-hardening] [RFC v4 03/18] bpf,landlock: Add a new
 arraymap type to deal with (Landlock) handles
References: <20161026065654.19166-1-mic@digikod.net>
 <20161026065654.19166-4-mic@digikod.net> <20161026190147.GN3334@pc.thejh.net>
In-Reply-To: <20161026190147.GN3334@pc.thejh.net>

--DidUHIrNlB58OejuDToDi6kWuLie2SJ5l
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable



On 26/10/2016 21:01, Jann Horn wrote:
> On Wed, Oct 26, 2016 at 08:56:39AM +0200, Micka=EBl Sala=FCn wrote:
>> This new arraymap looks like a set and brings new properties:
>> * strong typing of entries: the eBPF functions get the array type of
>>   elements instead of CONST_PTR_TO_MAP (e.g.
>>   CONST_PTR_TO_LANDLOCK_HANDLE_FS);
>> * force sequential filling (i.e. replace or append-only update), which=

>>   allow quick browsing of all entries.
>>
>> This strong typing is useful to statically check if the content of a m=
ap
>> can be passed to an eBPF function. For example, Landlock use it to sto=
re
>> and manage kernel objects (e.g. struct file) instead of dealing with
>> userland raw data. This improve efficiency and ensure that an eBPF
>> program can only call functions with the right high-level arguments.
>>
>> The enum bpf_map_handle_type list low-level types (e.g.
>> BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD) which are identified when
>> updating a map entry (handle). This handle types are used to infer a
>> high-level arraymap type which are listed in enum bpf_map_array_type
>> (e.g. BPF_MAP_ARRAY_TYPE_LANDLOCK_FS).
>>
>> For now, this new arraymap is only used by Landlock LSM (cf. next
>> commits) but it could be useful for other needs.
>>
>> Changes since v3:
>> * make handle arraymap safe (RCU) and remove buggy synchronize_rcu()
>> * factor out the arraymay walk
>>
>> Changes since v2:
>> * add a RLIMIT_NOFILE-based limit to the maximum number of arraymap
>>   handle entries (suggested by Andy Lutomirski)
>> * remove useless checks
>>
>> Changes since v1:
>> * arraymap of handles replace custom checker groups
>> * simpler userland API
> [...]
>> +	case BPF_MAP_HANDLE_TYPE_LANDLOCK_FS_FD:
>> +		handle_file =3D fget(handle->fd);
>> +		if (IS_ERR(handle_file))
>> +			return ERR_CAST(handle_file);
>> +		/* check if the FD is tied to a user mount point */
>> +		if (unlikely(handle_file->f_path.mnt->mnt_flags & MNT_INTERNAL)) {
>> +			fput(handle_file);
>> +			return ERR_PTR(-EINVAL);
>> +		}
>> +		path_get(&handle_file->f_path);
>> +		ret =3D kmalloc(sizeof(*ret), GFP_KERNEL);
>> +		ret->path =3D handle_file->f_path;
>> +		fput(handle_file);
>=20
> You can use fdget() and fdput() here because the reference to
> handle_file is dropped before the end of the syscall.

The reference to handle_file is dropped but not the reference to the
(inner) path thanks to path_get().

>=20
>=20
>> +		break;
>> +	case BPF_MAP_HANDLE_TYPE_UNSPEC:
>> +	default:
>> +		return ERR_PTR(-EINVAL);
>> +	}
>> +	ret->type =3D handle_type;
>> +	return ret;
>> +}
>> +
>> +static void *nop_map_lookup_elem(struct bpf_map *map, void *key)
>> +{
>> +	return ERR_PTR(-EINVAL);
>> +}
>> +
>> +/* called from syscall or from eBPF program */
>> +static int landlock_array_map_update_elem(struct bpf_map *map, void *=
key,
>> +		void *value, u64 map_flags)
>> +{
>=20
> This being callable from eBPF context is IMO pretty surprising and shou=
ld
> at least be well-documented. Also: What is the usecase here?
>=20

This may be callable but is restricted to CAP_SYS_ADMIN. Any update with
an FD should indeed be denied, but updates with raw values (e.g. GLOB,
IP or port numbers, not yet implemented) may be allowed. Because an eBPF
program is trusted by the process which loaded it (and have the same
rights), this program should be able to update a map like its creator
process. One usecase may be to adjust a map of handles by removing
entries or tightening them (i.e. drop privileges) when a specific
behavior of a monitored process is detected by the eBPF program.

I'm going to fix this update-with-FD case which make no sense anyway.

Thanks,
 Micka=EBl


--DidUHIrNlB58OejuDToDi6kWuLie2SJ5l--

--eanIdfAB2UJqb9odiraaGVVLRF65XF93a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJYEQv9AAoJECLe/t9zvWqVSmMIAIdDuafVOTBy6mGTfi7An3yG
1ftM3qK9z8ZEdLGMycWAuCMgReaIS2o1iarMlX0sE8kHfkibD5qgqV+4TQNWyOp7
q6WCOS9Ykbscsiw3NMdCz8HBICvFJj0QlqQJYrtONu7XiEyLqUbjQYjqSOBoZlhS
0CoNO8VsgrNkPlIxlYr+Xojdj9X3KLTEgWUtKe6DfqYReZy0/4dWUVDFs5Oz2wWX
ykpi2ps8ebjlMTU+7l5OMzpdsdh5yINmrG/sYP1FAZLh+pGOHzsE+ENJeUjBWQxo
9SOFuf40fH9kujlnC59ZT5dViZKiSRuozzdJOStjwljCPiZfK41+G8x8ZszVy2c=
=8gQd
-----END PGP SIGNATURE-----

--eanIdfAB2UJqb9odiraaGVVLRF65XF93a--
