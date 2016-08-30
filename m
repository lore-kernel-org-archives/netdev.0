From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 06/10] landlock: Add LSM hooks
Date: Tue, 30 Aug 2016 22:10:39 +0200
Message-ID: <57C5E83F.4000102@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-7-git-send-email-mic@digikod.net>
 <CALCETrXRXxQ26caQW6Vh-NriDeSvnOb=yAu-F=3pvmd0Py+1Pg@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="q4baTCNlCIdcs24GXD4Lc8aKKqNVwLP2d"
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
Return-path: <kernel-hardening-return-4510-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrXRXxQ26caQW6Vh-NriDeSvnOb=yAu-F=3pvmd0Py+1Pg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--q4baTCNlCIdcs24GXD4Lc8aKKqNVwLP2d
Content-Type: multipart/mixed; boundary="vgLrvRiMv0fCqHB0WcX0hmlTLgDeqHfUv";
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
Message-ID: <57C5E83F.4000102@digikod.net>
Subject: Re: [RFC v2 06/10] landlock: Add LSM hooks
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-7-git-send-email-mic@digikod.net>
 <CALCETrXRXxQ26caQW6Vh-NriDeSvnOb=yAu-F=3pvmd0Py+1Pg@mail.gmail.com>
In-Reply-To: <CALCETrXRXxQ26caQW6Vh-NriDeSvnOb=yAu-F=3pvmd0Py+1Pg@mail.gmail.com>

--vgLrvRiMv0fCqHB0WcX0hmlTLgDeqHfUv
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 30/08/2016 20:56, Andy Lutomirski wrote:
> On Aug 25, 2016 12:34 PM, "Micka=C3=ABl Sala=C3=BCn" <mic@digikod.net> =
wrote:
>>
>> Add LSM hooks which can be used by userland through Landlock (eBPF)
>> programs. This programs are limited to a whitelist of functions (cf.
>> next commit). The eBPF program context is depicted by the struct
>> landlock_data (cf. include/uapi/linux/bpf.h):
>> * hook: LSM hook ID (useful when using the same program for multiple L=
SM
>>   hooks);
>> * cookie: the 16-bit value from the seccomp filter that triggered this=

>>   Landlock program;
>> * args[6]: array of LSM hook arguments.
>>
>> The LSM hook arguments can contain raw values as integers or
>> (unleakable) pointers. The only way to use the pointers are to pass th=
em
>> to an eBPF function according to their types (e.g. the
>> bpf_landlock_cmp_fs_beneath_with_struct_file function can use a struct=

>> file pointer).
>>
>> For now, there is three hooks for file system access control:
>> * file_open;
>> * file_permission;
>> * mmap_file.
>>
>=20
> What's the purpose of exposing struct cred * to userspace?  It's
> primarily just an optimization to save a bit of RAM, and it's a
> dubious optimization at that.  What are you using it for?  Would it
> make more sense to use struct task_struct * or struct pid * instead?
>=20
> Also, exposing struct cred * has a really weird side-effect: it allows
> (maybe even encourages) checking for pointer equality between two
> struct cred * objects.  Doing so will have erratic results.
>=20

The pointers exposed in the ePBF context are not directly readable by an
unprivileged eBPF program thanks to the strong typing of the Landlock
context and the static eBPF verification. There is no way to leak a
kernel pointer to userspace from an unprivileged eBPF program: pointer
arithmetic and comparison are prohibited. Pointers can only be pass as
argument to dedicated eBPF functions.

For now, struct cred * is simply not used by any eBPF function and then
not usable at all. It only exist here because I map the LSM hook
arguments in a generic/automatic way to the eBPF context.

I'm planning to extend the Landlock context with extra pointers,
whatever the LSM hook. We could then use task_struct, skb or any other
kernel objects, in a safe way, with dedicated functions.


--vgLrvRiMv0fCqHB0WcX0hmlTLgDeqHfUv--

--q4baTCNlCIdcs24GXD4Lc8aKKqNVwLP2d
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXxehAAAoJECLe/t9zvWqVO4cH+wQMEP+glVQA4Cq1jDX9aC7B
2JDsiuoKepZb7kPUPiFguT751b6zIJd75Lx8XmDLFN5Yoxt7jzb6EIosvcFWOTWp
aReN+U9Jg2+W7DHylXjByT/+vTrGZoWkNdZAoqWa9KgPMAJm69thZcieUhpNDtob
S334bYOmWFtAYTbggm7JWzopYk0yutvN9xsltbNqW0K5UTzc/dSRKjxwN39BtB/u
J13qkNbHCEwJ540iGej2UyBrj91vBaBwktP+WIMBy6HCrZ6DIY0AI2hlsK11ihUn
lTJOmF57hq+3XKmVGCdKbiHffEAuhSsxXkIYmglA9lW2BB9hT0vitF1g/W7GGEo=
=Va2h
-----END PGP SIGNATURE-----

--q4baTCNlCIdcs24GXD4Lc8aKKqNVwLP2d--
