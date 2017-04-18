From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v6 04/11] landlock: Add LSM hooks related to
 filesystem
Date: Wed, 19 Apr 2017 00:44:07 +0200
Message-ID: <9a69055a-b4cf-00b0-da5e-2e45ff88059c@digikod.net>
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-5-mic@digikod.net>
 <CAGXu5jJKNp8R5kZ1U=K7KwgnV=NvH5aoAbftA-05a_Sa4pOg1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="TannIoxLCqj0FPurQb4N5KciaUeTOPnkx"
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
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
        Paul Moore <paul@paul-moore.com>, Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Will Drewry <wad@chromium.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <kernel-hardening-return-7403-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5jJKNp8R5kZ1U=K7KwgnV=NvH5aoAbftA-05a_Sa4pOg1Q@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--TannIoxLCqj0FPurQb4N5KciaUeTOPnkx
Content-Type: multipart/mixed; boundary="BN6JkqHCUl9Tf2tviv77DuxJvHN8aUESh";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, David Drysdale
 <drysdale@google.com>, "David S . Miller" <davem@davemloft.net>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
 Jonathan Corbet <corbet@lwn.net>, Matthew Garrett <mjg59@srcf.ucam.org>,
 Michael Kerrisk <mtk.manpages@gmail.com>, Paul Moore <paul@paul-moore.com>,
 Sargun Dhillon <sargun@sargun.me>, "Serge E . Hallyn" <serge@hallyn.com>,
 Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
 Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 linux-security-module <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>
Message-ID: <9a69055a-b4cf-00b0-da5e-2e45ff88059c@digikod.net>
Subject: Re: [PATCH net-next v6 04/11] landlock: Add LSM hooks related to
 filesystem
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-5-mic@digikod.net>
 <CAGXu5jJKNp8R5kZ1U=K7KwgnV=NvH5aoAbftA-05a_Sa4pOg1Q@mail.gmail.com>
In-Reply-To: <CAGXu5jJKNp8R5kZ1U=K7KwgnV=NvH5aoAbftA-05a_Sa4pOg1Q@mail.gmail.com>

--BN6JkqHCUl9Tf2tviv77DuxJvHN8aUESh
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 19/04/2017 00:17, Kees Cook wrote:
> On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
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
>> Changes since v5:
>> * split hooks.[ch] into hooks.[ch] and hooks_fs.[ch]
>> * add more documentation
>> * cosmetic fixes
>>
>> Changes since v4:
>> * add LSM hook abstraction called Landlock event
>>   * use the compiler type checking to verify hooks use by an event
>>   * handle all filesystem related LSM hooks (e.g. file_permission,
>>     mmap_file, sb_mount...)
>> * register BPF programs for Landlock just after LSM hooks registration=

>> * move hooks registration after other LSMs
>> * add failsafes to check if a hook is not used by the kernel
>> * allow partial raw value access form the context (needed for programs=

>>   generated by LLVM)
>>
>> Changes since v3:
>> * split commit
>> * add hooks dealing with struct inode and struct path pointers:
>>   inode_permission and inode_getattr
>> * add abstraction over eBPF helper arguments thanks to wrapping struct=
s
>>
>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>> Cc: Alexei Starovoitov <ast@kernel.org>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: James Morris <james.l.morris@oracle.com>
>> Cc: Kees Cook <keescook@chromium.org>
>> Cc: Serge E. Hallyn <serge@hallyn.com>
>> ---
>>  include/linux/lsm_hooks.h    |   5 +
>>  security/landlock/Makefile   |   4 +-
>>  security/landlock/hooks.c    | 115 +++++++++
>>  security/landlock/hooks.h    | 177 ++++++++++++++
>>  security/landlock/hooks_fs.c | 563 ++++++++++++++++++++++++++++++++++=
+++++++++
>>  security/landlock/hooks_fs.h |  19 ++
>>  security/landlock/init.c     |  13 +
>>  security/security.c          |   7 +-
>>  8 files changed, 901 insertions(+), 2 deletions(-)
>>  create mode 100644 security/landlock/hooks.c
>>  create mode 100644 security/landlock/hooks.h
>>  create mode 100644 security/landlock/hooks_fs.c
>>  create mode 100644 security/landlock/hooks_fs.h
>>
>> diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
>> index e29d4c62a3c8..884289166a0e 100644
>> --- a/include/linux/lsm_hooks.h
>> +++ b/include/linux/lsm_hooks.h
>> @@ -1920,5 +1920,10 @@ void __init loadpin_add_hooks(void);
>>  #else
>>  static inline void loadpin_add_hooks(void) { };
>>  #endif
>> +#ifdef CONFIG_SECURITY_LANDLOCK
>> +extern void __init landlock_add_hooks(void);
>> +#else
>> +static inline void __init landlock_add_hooks(void) { }
>> +#endif /* CONFIG_SECURITY_LANDLOCK */
>>
>>  #endif /* ! __LINUX_LSM_HOOKS_H */
>> diff --git a/security/landlock/Makefile b/security/landlock/Makefile
>> index 7205f9a7a2ee..c0db504a6335 100644
>> --- a/security/landlock/Makefile
>> +++ b/security/landlock/Makefile
>> @@ -1,3 +1,5 @@
>> +ccflags-$(CONFIG_SECURITY_LANDLOCK) +=3D -Werror=3Dunused-function
>=20
> Why is this needed? If it can't be avoided, a comment should exist
> here explaining why.

This is useful to catch defined but unused hooks: error out if a
HOOK_NEW_FS(foo) is not used with a HOOK_INIT_FS(foo) in the struct
security_hook_list landlock_hooks.

>=20
>> [...]
>> @@ -127,3 +132,11 @@ static struct bpf_prog_type_list bpf_landlock_typ=
e __ro_after_init =3D {
>>         .ops =3D &bpf_landlock_ops,
>>         .type =3D BPF_PROG_TYPE_LANDLOCK,
>>  };
>> +
>> +void __init landlock_add_hooks(void)
>> +{
>> +       pr_info("landlock: Version %u", LANDLOCK_VERSION);
>> +       landlock_add_hooks_fs();
>> +       security_add_hooks(NULL, 0, "landlock");
>> +       bpf_register_prog_type(&bpf_landlock_type);
>=20
> I'm confused by the separation of hook registration here. The call to
> security_add_hooks is with count=3D0 is especially weird. Why isn't thi=
s
> just a single call with security_add_hooks(landlock_hooks,
> ARRAY_SIZE(landlock_hooks), "landlock")?

Yes, this is ugly with the new security_add_hooks() with three arguments
but I wanted to split the hooks definition in multiple files.

The current security_add_hooks() use lsm_append(lsm, &lsm_names) which
is not exported. Unfortunately, calling multiple security_add_hooks()
with the same LSM name would register multiple names for the same LSM=E2=80=
=A6
Is it OK if I modify this function to not add duplicated entries?


>=20
>> +}
>> diff --git a/security/security.c b/security/security.c
>> index d0e07f269b2d..a3e9f4625991 100644
>> --- a/security/security.c
>> +++ b/security/security.c
>> @@ -64,10 +64,15 @@ int __init security_init(void)
>>         loadpin_add_hooks();
>>
>>         /*
>> -        * Load all the remaining security modules.
>> +        * Load all remaining privileged security modules.
>>          */
>>         do_security_initcalls();
>>
>> +       /*
>> +        * Load potentially-unprivileged security modules at the end.
>> +        */
>> +       landlock_add_hooks();
>=20
> Oh, is this to make it last in the list? Is there a reason it has to be=
 last?

Right, this is the intend. I'm not sure it is the only way to register
hooks, though.

For an unprivileged access-control, we don't want to give the ability to
any process to do some checks, through an eBPF program, on kernel
objects (e.g. files) if they should not be accessible (because of a
following LSM hook check).

 Micka=C3=ABl


--BN6JkqHCUl9Tf2tviv77DuxJvHN8aUESh--

--TannIoxLCqj0FPurQb4N5KciaUeTOPnkx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlj2lrgACgkQIt7+33O9
apUiWQgAkhjxJ6dnxaTF10HmhF1ooLIwZTxpFnxCHbDU89bVqfOvFylt0dLR1u9g
RlODgGQ5rMXm8HjCLAOUyF3OK/oSg/IqbrcD7KSqsuEdJTKZCRP0vQBVDnQPDYR7
Gd0NFcLEon+rTaLR3ygiN739kuFnHB9ihbqw+ijPTcKBE4EVvvCCaJ5ZV7vEu3nv
+iIcAay4D103O+kHk6Mb0F/LQc0pREftuetDGMxOT1oim1YSZ2FifDSIvJ6R9Jsk
KZoCxMwLAVoLYzVHSUyQ5F2m+s8CrAHM4v4379wmucLNI869PaVappvJA7JGxa+D
fotD3+wD0FuzNdE5ukVq/svfN/CEmQ==
=iq4F
-----END PGP SIGNATURE-----

--TannIoxLCqj0FPurQb4N5KciaUeTOPnkx--
