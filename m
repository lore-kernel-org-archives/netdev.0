From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v7 05/10] landlock: Add LSM hooks related to
 filesystem
Date: Sun, 27 Aug 2017 15:31:35 +0200
Message-ID: <3325bd7d-f3d8-2f51-384c-b5e8cee5cb91@digikod.net>
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-6-mic@digikod.net>
 <20170824025030.sxl2hkpcbzipb47y@ast-mbp>
 <22d09137-7212-5803-af64-0964fad875c7@digikod.net>
 <20170826011614.iqya5dqii3n7dtdb@ast-mbp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Lh2xJxXOSSx0wSk4vbpEfPbavIUEP8vSP"
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
Return-path: <kernel-hardening-return-9568-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170826011614.iqya5dqii3n7dtdb@ast-mbp>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Lh2xJxXOSSx0wSk4vbpEfPbavIUEP8vSP
Content-Type: multipart/mixed; boundary="TaQgj9h8cdmIerbLDIKchXjEvvCtnusMt";
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
Message-ID: <3325bd7d-f3d8-2f51-384c-b5e8cee5cb91@digikod.net>
Subject: Re: [PATCH net-next v7 05/10] landlock: Add LSM hooks related to
 filesystem
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-6-mic@digikod.net>
 <20170824025030.sxl2hkpcbzipb47y@ast-mbp>
 <22d09137-7212-5803-af64-0964fad875c7@digikod.net>
 <20170826011614.iqya5dqii3n7dtdb@ast-mbp>
In-Reply-To: <20170826011614.iqya5dqii3n7dtdb@ast-mbp>

--TaQgj9h8cdmIerbLDIKchXjEvvCtnusMt
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 26/08/2017 03:16, Alexei Starovoitov wrote:
> On Fri, Aug 25, 2017 at 10:16:39AM +0200, Micka=EBl Sala=FCn wrote:

>>>
>>>> +/* a directory inode contains only one dentry */
>>>> +HOOK_NEW_FS(inode_create, 3,
>>>> +	struct inode *, dir,
>>>> +	struct dentry *, dentry,
>>>> +	umode_t, mode,
>>>> +	WRAP_ARG_INODE, dir,
>>>> +	WRAP_ARG_RAW, LANDLOCK_ACTION_FS_WRITE
>>>> +);
>>>
>>> more general question: why you're not wrapping all useful
>>> arguments? Like in the above dentry can be acted upon
>>> by the landlock rule and it's readily available...
>>
>> The context used for the FS event must have the exact same types for a=
ll
>> calls. This event is meant to be generic but we can add more specific
>> ones if needed, like I do with FS_IOCTL.
>=20
> I see. So all FS events will have dentry as first argument
> regardless of how it is in LSM hook ?

All FS events will have a const struct bpf_handle_fs pointer as first
argument, which wrap either a struct file, a struct dentry, a struct
path or a struct inode. Having only one type (struct bpf_handle_fs) is
needed for the eBPF type checker to verify if a Landlock rule (tied to
an event) can access a context field and which operation is allowed
(with this pointer).

> I guess that will simplify the rules indeed.
> I suspect you're doing it to simplify the LSM->landlock shim layer as w=
ell, right?

That's right. This ABI is independent from the LSM API and much more
simpler to use.

>=20
>> The idea is to enable people to write simple rules, while being able t=
o
>> write fine grain rules for special cases (e.g. IOCTL) if needed.
>>
>>>
>>> The limitation of only 2 args looks odd.
>>> Is it a hard limitation ? how hard to extend?
>>
>> It's not a hard limit at all. Actually, the FS_FNCTL event should have=

>> three arguments (I'll add them in the next series): FS handle, FCNTL
>> command and FCNTL argument. I made sure that it's really easy to add
>> more arguments to the context of an event.
>=20
> The reason I'm asking, because I'm not completely convinced that
> adding another argument to existing event will be backwards compatible.=

> It looks like you're expecting only two args for all FS events, right?

There is four events right now: FS, FS_IOCTL, FS_LOCK and FS_FCNTL. Each
of them are independent. Their context fields can be of the same or
different eBPF type (e.g. scalar, file handle) and numbers. Actually,
these four events have the same arg1 field (file handle) and the same
arg2 eBPF type (scalar), even if arg2 does not have the same semantic
(i.e. abstract FS action, IOCTL command=85).

For example, if we want to extend the FS_FCNTL's context in the future,
we will just have to add an arg3. The check is performed in
landlock_is_valid_access() and landlock_decide(). If a field is not used
by an event, then this field will have a NOT_INIT type and accessing it
will be denied.

> How can you add 3rd argument? All FS events would have to get it,
> but in some LSM hooks such argument will be meaningless, whereas
> in other places it will carry useful info that rule can operate on.
> Would that mean that we'll have FS_3 event type and only few LSM
> hooks will be converted to it. That works, but then we'll lose
> compatiblity with old rules written for FS event and that given hook.
> Otherwise we'd need to have fancy logic to accept old FS event
> into FS_3 LSM hook.

If we want to add a third argument to the FS event, then it will become
accessible because its type will be different than NOT_INIT. This keep
the compatibility with old rules because this new field was then denied.

If we want to add a new argument but only for a subset of the hooks used
by the FS event, then we need to create a new event, like FS_FCNTL. For
example, we may want to add a FS_RENAME event to be able to tie the
source file and the destination file of a rename call.

Anyway, I added the subtype/ABI version as a safeguard in case of
unexpected future evolution.


--TaQgj9h8cdmIerbLDIKchXjEvvCtnusMt--

--Lh2xJxXOSSx0wSk4vbpEfPbavIUEP8vSP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlmiybcACgkQIt7+33O9
apWV9Qf+Lm0tr+5ID4QjMnUfXZrDJBl+CHbCjL1tpK8RWyzDmJitUOTzcWRxwQ8M
voGK9y0ThfRHiXc3/BJlYym78rzm69+oEhfVSyYDDcVOjNu9QmP2c7if8ZKryzuo
mpzFC6iCx1Z8st3Bdtit/mwxKjgp7zL4WRTAO+kykplQMs4jn1ZuE+V+uVNNBKql
XLMOJo1FDcNIqiC5NBAnpo/IyDNkIITSFmSebx8CVb+P8DqbhPjFu8TfVgra7i5T
rRoUC+RT0USAHIAboWzHPZIZWbDoTqUhBxuWJqOYJiwTYBCgUEQZpdMXc1xBaIli
j0HegoL9Ozmds/FB2iBuO2wOF7xOeA==
=UufW
-----END PGP SIGNATURE-----

--Lh2xJxXOSSx0wSk4vbpEfPbavIUEP8vSP--
