From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (program types)
Date: Sat, 27 Aug 2016 16:34:55 +0200
Message-ID: <57C1A50F.60605@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="UJCILjBJ49pKIqv7c57p9OiCUgIKp5eqo"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Daniel Borkmann
 <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        "David S . Miller" <davem@davemloft.net>,
        Kees Cook <keescook@chromium.org>, Sargun Dhillon <sargun@sargun.me>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        Tejun Heo <tj@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <kernel-hardening-return-4485-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160826230539.GA26683@ast-mbp.thefacebook.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--UJCILjBJ49pKIqv7c57p9OiCUgIKp5eqo
Content-Type: multipart/mixed; boundary="EcTFwxMO4xrUr4JB7meVvf4H9AtI5xrAr"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Daniel Borkmann
 <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 "David S . Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>,
 Sargun Dhillon <sargun@sargun.me>, kernel-hardening@lists.openwall.com,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>
Message-ID: <57C1A50F.60605@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (program types)
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
In-Reply-To: <20160826230539.GA26683@ast-mbp.thefacebook.com>

--EcTFwxMO4xrUr4JB7meVvf4H9AtI5xrAr
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 27/08/2016 01:05, Alexei Starovoitov wrote:
> On Fri, Aug 26, 2016 at 05:10:40PM +0200, Micka=EBl Sala=FCn wrote:
>
>>> As far as safety and type checking that bpf programs has to do,
>>> I like the approach of patch 06/10:
>>> +LANDLOCK_HOOK2(file_open, FILE_OPEN,
>>> +       PTR_TO_STRUCT_FILE, struct file *, file,
>>> +       PTR_TO_STRUCT_CRED, const struct cred *, cred
>>> +)
>>> teaching verifier to recognize struct file, cred, sockaddr
>>> will let bpf program access them naturally without any overhead.
>>> Though:
>>> @@ -102,6 +102,9 @@ enum bpf_prog_type {
>>>         BPF_PROG_TYPE_SCHED_CLS,
>>>         BPF_PROG_TYPE_SCHED_ACT,
>>>         BPF_PROG_TYPE_TRACEPOINT,
>>> +       BPF_PROG_TYPE_LANDLOCK_FILE_OPEN,
>>> +       BPF_PROG_TYPE_LANDLOCK_FILE_PERMISSION,
>>> +       BPF_PROG_TYPE_LANDLOCK_MMAP_FILE,
>>>  };
>>> is a bit of overkill.
>>> I think it would be cleaner to have single
>>> BPF_PROG_TYPE_LSM and at program load time pass
>>> lsm_hook_id as well, so that verifier can do safety checks
>>> based on type info provided in LANDLOCK_HOOKs
>>
>> I first started with a unique BPF_PROG_TYPE but, the thing is, the BPF=

>> verifier check programs according to their types. If we need to check
>> specific context value types (e.g. PTR_TO_STRUCT_FILE), we need a
>> dedicated program types. I don't see any other way to do it with the
>> current verifier code. Moreover it's the purpose of program types, rig=
ht?
>=20
> Adding new bpf program type for every lsm hook is not acceptable.
> Either do one new program type + pass lsm_hook_id as suggested
> or please come up with an alternative approach.

OK, so we have to modify the verifier to not only rely on the program
type but on another value to check the context accesses. Do you have a
hint from where this value could come from? Do we need to add a new bpf
command to associate a program to a subtype?


--EcTFwxMO4xrUr4JB7meVvf4H9AtI5xrAr--

--UJCILjBJ49pKIqv7c57p9OiCUgIKp5eqo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXwaUQAAoJECLe/t9zvWqVr8AIAJJUHrL3vkMSUYwYnMXh+KTd
JlFt5bZREQSkctvFcdb6Ynt+DdI0eMuNGyxYqh4TiqV2sqW8htOpyqdjbzzUv3g2
/HTP/V0WGNZu31C7Tj5Wiw1guBKg9HfTAzrGjDh35ZXs5EWVe1gglR8+0ocA8qdB
2c7JZPiOiLTXhWO2YcSe0020KQ3qNLfr5RrPROAwfNdwDsQhf0fjkQNajm9Qzj/2
FwEGPnEjmrkddWQ4KcKuJOeyewDPzLLo1iba2+j+u+zpyX9gb7wcLWSiIz9N/c2O
dwK+bNdXE2xcL7TkBXwFSk4dNyGPzN26enqHwcCvqdbdXXyl9qZ7pubG0TUjgII=
=73Hj
-----END PGP SIGNATURE-----

--UJCILjBJ49pKIqv7c57p9OiCUgIKp5eqo--
