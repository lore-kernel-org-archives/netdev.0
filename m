From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 06/10] landlock: Add LSM hooks
Date: Tue, 30 Aug 2016 22:27:50 +0200
Message-ID: <57C5EC46.3050804@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-7-git-send-email-mic@digikod.net>
 <CALCETrXRXxQ26caQW6Vh-NriDeSvnOb=yAu-F=3pvmd0Py+1Pg@mail.gmail.com>
 <57C5E83F.4000102@digikod.net>
 <CALCETrUK1umtXMEXXKzMAccNQCVTPA8_XNDf01B5=gAZuJwvsQ@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="eP4avamU9xrubB7MKTWkEss1Eq1WoM46R"
Cc: "Serge E. Hallyn" <serge@hallyn.com>,
        David Drysdale
 <drysdale@google.com>,
        "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
        Alexei Starovoitov <ast@kernel.org>,
        James Morris
 <james.l.morris@oracle.com>,
        Sargun Dhillon <sargun@sargun.me>,
        Network Development <netdev@vger.kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Linux API <linux-api@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Mack <daniel@zonque.org>, Arnd Bergmann <arnd@arndb.de>,
        Will Drewry <wad@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Elena Reshetova <elena.reshetova@intel.com>,
        Daniel Bo
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4514-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrUK1umtXMEXXKzMAccNQCVTPA8_XNDf01B5=gAZuJwvsQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--eP4avamU9xrubB7MKTWkEss1Eq1WoM46R
Content-Type: multipart/mixed; boundary="Vs2smWFitaNCKminiHOihlsIS6Cx037iO";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Serge E. Hallyn" <serge@hallyn.com>, David Drysdale
 <drysdale@google.com>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 Alexei Starovoitov <ast@kernel.org>, James Morris
 <james.l.morris@oracle.com>, Sargun Dhillon <sargun@sargun.me>,
 Network Development <netdev@vger.kernel.org>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Linux API <linux-api@vger.kernel.org>, Kees Cook <keescook@chromium.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "David S . Miller" <davem@davemloft.net>, Daniel Mack <daniel@zonque.org>,
 Arnd Bergmann <arnd@arndb.de>, Will Drewry <wad@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Elena Reshetova <elena.reshetova@intel.com>,
 Daniel Borkmann <daniel@iogearbox.net>
Message-ID: <57C5EC46.3050804@digikod.net>
Subject: Re: [RFC v2 06/10] landlock: Add LSM hooks
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-7-git-send-email-mic@digikod.net>
 <CALCETrXRXxQ26caQW6Vh-NriDeSvnOb=yAu-F=3pvmd0Py+1Pg@mail.gmail.com>
 <57C5E83F.4000102@digikod.net>
 <CALCETrUK1umtXMEXXKzMAccNQCVTPA8_XNDf01B5=gAZuJwvsQ@mail.gmail.com>
In-Reply-To: <CALCETrUK1umtXMEXXKzMAccNQCVTPA8_XNDf01B5=gAZuJwvsQ@mail.gmail.com>

--Vs2smWFitaNCKminiHOihlsIS6Cx037iO
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 30/08/2016 22:18, Andy Lutomirski wrote:
> On Tue, Aug 30, 2016 at 1:10 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>>
>> On 30/08/2016 20:56, Andy Lutomirski wrote:
>>> On Aug 25, 2016 12:34 PM, "Micka=C3=ABl Sala=C3=BCn" <mic@digikod.net=
> wrote:
>>>>
>>>> Add LSM hooks which can be used by userland through Landlock (eBPF)
>>>> programs. This programs are limited to a whitelist of functions (cf.=

>>>> next commit). The eBPF program context is depicted by the struct
>>>> landlock_data (cf. include/uapi/linux/bpf.h):
>>>> * hook: LSM hook ID (useful when using the same program for multiple=
 LSM
>>>>   hooks);
>>>> * cookie: the 16-bit value from the seccomp filter that triggered th=
is
>>>>   Landlock program;
>>>> * args[6]: array of LSM hook arguments.
>>>>
>>>> The LSM hook arguments can contain raw values as integers or
>>>> (unleakable) pointers. The only way to use the pointers are to pass =
them
>>>> to an eBPF function according to their types (e.g. the
>>>> bpf_landlock_cmp_fs_beneath_with_struct_file function can use a stru=
ct
>>>> file pointer).
>>>>
>>>> For now, there is three hooks for file system access control:
>>>> * file_open;
>>>> * file_permission;
>>>> * mmap_file.
>>>>
>>>
>>> What's the purpose of exposing struct cred * to userspace?  It's
>>> primarily just an optimization to save a bit of RAM, and it's a
>>> dubious optimization at that.  What are you using it for?  Would it
>>> make more sense to use struct task_struct * or struct pid * instead?
>>>
>>> Also, exposing struct cred * has a really weird side-effect: it allow=
s
>>> (maybe even encourages) checking for pointer equality between two
>>> struct cred * objects.  Doing so will have erratic results.
>>>
>>
>> The pointers exposed in the ePBF context are not directly readable by =
an
>> unprivileged eBPF program thanks to the strong typing of the Landlock
>> context and the static eBPF verification. There is no way to leak a
>> kernel pointer to userspace from an unprivileged eBPF program: pointer=

>> arithmetic and comparison are prohibited. Pointers can only be pass as=

>> argument to dedicated eBPF functions.
>=20
> I'm not talking about leaking the value -- I'm talking about leaking
> the predicate (a =3D=3D b) for two struct cred pointers.  That predicat=
e
> shouldn't be available because it has very odd effects.

I'm pretty sure this case is covered with the impossibility of doing
pointers comparison.

>=20
>>
>> For now, struct cred * is simply not used by any eBPF function and the=
n
>> not usable at all. It only exist here because I map the LSM hook
>> arguments in a generic/automatic way to the eBPF context.
>=20
> Maybe remove it from this patch set then?

Well, this is done with the LANDLOCK_HOOK* macros but I will remove it.


--Vs2smWFitaNCKminiHOihlsIS6Cx037iO--

--eP4avamU9xrubB7MKTWkEss1Eq1WoM46R
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXxexGAAoJECLe/t9zvWqVe+cIAIQWGn2xjjPR73C6Q+5wWiFA
AEkwcYWkp8053/enQwerXQxmqrBJbVrzh1C7LH4Dedc2zaggdfsqWm8gC/4AESMh
Bygx0SSvrbCVymcKRe1oDRxqvAlYScqKhcg3UmNihlijYoGfiMhaiOnCYdmIYSgm
a4/aU7+LlscUr13IGwFgzOru/4ELSi1m2E6ZkSAoS23Ve6dd4VdLjQJCqXhobKud
SEcpNG0VZwwMMekKRhQr7YQiRmnRvV6nnrVxX2fHbvh0KqWXKx5Oq5x0BV6mxWwf
tbZJ93mrQJwRUm6sJLXiy46TV9J0ozCx1Dezzi1wwAD7MHp7oPOdWA67XhJ7tcg=
=mvOL
-----END PGP SIGNATURE-----

--eP4avamU9xrubB7MKTWkEss1Eq1WoM46R--
