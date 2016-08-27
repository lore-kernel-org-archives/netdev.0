From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (program types)
Date: Sat, 27 Aug 2016 23:18:23 +0200
Message-ID: <57C2039F.300@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com> <57C1A50F.60605@digikod.net>
 <20160827181939.GC38754@ast-mbp.thefacebook.com>
 <57C1F015.1000301@digikod.net>
 <20160827205559.GA43880@ast-mbp.thefacebook.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="okBLDKC1NTVRpHolO4chbiAqDNLXD2fGL"
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
Return-path: <kernel-hardening-return-4497-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160827205559.GA43880@ast-mbp.thefacebook.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--okBLDKC1NTVRpHolO4chbiAqDNLXD2fGL
Content-Type: multipart/mixed; boundary="gExqfHWr5AJTvHSighOexSQSrnjg5DLfI"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Daniel Borkmann
 <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 "David S . Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>,
 Sargun Dhillon <sargun@sargun.me>, kernel-hardening@lists.openwall.com,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>
Message-ID: <57C2039F.300@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (program types)
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com> <57C1A50F.60605@digikod.net>
 <20160827181939.GC38754@ast-mbp.thefacebook.com>
 <57C1F015.1000301@digikod.net>
 <20160827205559.GA43880@ast-mbp.thefacebook.com>
In-Reply-To: <20160827205559.GA43880@ast-mbp.thefacebook.com>

--gExqfHWr5AJTvHSighOexSQSrnjg5DLfI
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 27/08/2016 22:56, Alexei Starovoitov wrote:
> On Sat, Aug 27, 2016 at 09:55:01PM +0200, Micka=EBl Sala=FCn wrote:
>>
>> On 27/08/2016 20:19, Alexei Starovoitov wrote:
>>> On Sat, Aug 27, 2016 at 04:34:55PM +0200, Micka=EBl Sala=FCn wrote:
>>>>
>>>> On 27/08/2016 01:05, Alexei Starovoitov wrote:
>>>>> On Fri, Aug 26, 2016 at 05:10:40PM +0200, Micka=EBl Sala=FCn wrote:=

>>>>>
>>>>>>> As far as safety and type checking that bpf programs has to do,
>>>>>>> I like the approach of patch 06/10:
>>>>>>> +LANDLOCK_HOOK2(file_open, FILE_OPEN,
>>>>>>> +       PTR_TO_STRUCT_FILE, struct file *, file,
>>>>>>> +       PTR_TO_STRUCT_CRED, const struct cred *, cred
>>>>>>> +)
>>>>>>> teaching verifier to recognize struct file, cred, sockaddr
>>>>>>> will let bpf program access them naturally without any overhead.
>>>>>>> Though:
>>>>>>> @@ -102,6 +102,9 @@ enum bpf_prog_type {
>>>>>>>         BPF_PROG_TYPE_SCHED_CLS,
>>>>>>>         BPF_PROG_TYPE_SCHED_ACT,
>>>>>>>         BPF_PROG_TYPE_TRACEPOINT,
>>>>>>> +       BPF_PROG_TYPE_LANDLOCK_FILE_OPEN,
>>>>>>> +       BPF_PROG_TYPE_LANDLOCK_FILE_PERMISSION,
>>>>>>> +       BPF_PROG_TYPE_LANDLOCK_MMAP_FILE,
>>>>>>>  };
>>>>>>> is a bit of overkill.
>>>>>>> I think it would be cleaner to have single
>>>>>>> BPF_PROG_TYPE_LSM and at program load time pass
>>>>>>> lsm_hook_id as well, so that verifier can do safety checks
>>>>>>> based on type info provided in LANDLOCK_HOOKs
>>>>>>
>>>>>> I first started with a unique BPF_PROG_TYPE but, the thing is, the=
 BPF
>>>>>> verifier check programs according to their types. If we need to ch=
eck
>>>>>> specific context value types (e.g. PTR_TO_STRUCT_FILE), we need a
>>>>>> dedicated program types. I don't see any other way to do it with t=
he
>>>>>> current verifier code. Moreover it's the purpose of program types,=
 right?
>>>>>
>>>>> Adding new bpf program type for every lsm hook is not acceptable.
>>>>> Either do one new program type + pass lsm_hook_id as suggested
>>>>> or please come up with an alternative approach.
>>>>
>>>> OK, so we have to modify the verifier to not only rely on the progra=
m
>>>> type but on another value to check the context accesses. Do you have=
 a
>>>> hint from where this value could come from? Do we need to add a new =
bpf
>>>> command to associate a program to a subtype?
>>>
>>> It's another field prog_subtype (or prog_hook_id) in union bpf_attr.
>>> Both prog_type and prog_hook_id are used during verification.
>>> prog_type distinguishes the main aspects whereas prog_hook_id selects=

>>> which lsm_hook's argument definition to apply.
>>> At the time of attaching to a hook, the prog_hook_id passed at the
>>> load time should match lsm's hook_id.
>>
>> OK, so this new prog_subtype field should be use/set by a new bpf_cmd,=

>> right? Something like BPF_PROG_SUBTYPE or BPF_PROG_METADATA?
>=20
> No new command. It will be an optional field to existing BPF_PROG_LOAD.=

> In other words instead of replicating everything that different
> bpf_prog_type-s need, we can pass this hook_id field to fine tune
> the purpose (and applicability) of the program.
> And one BPF_PROG_TYPE_LANDLOCK type will cover all lsm hooks.
> For example existing BPF_PROG_TYPE_TRACEPOINT checks the safety
> for all tracepoints while they all have different arguments.
> For tracepoints it's easier, since the only difference between them
> is the range of ctx access. Here we need strong type safety
> of arguments therefore need extra hook_id at load time.

OK, I will do it.


--gExqfHWr5AJTvHSighOexSQSrnjg5DLfI--

--okBLDKC1NTVRpHolO4chbiAqDNLXD2fGL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXwgOfAAoJECLe/t9zvWqV9yEH/2ygrLafTr31A5wO7G2vyOux
Gji6f+cBfNBdTiguhZv/SorqQ2PytK4h/Q4SU0r3Erk4xF0KlAD/CPdSr54vDr6W
0jnf7pOnsrYwtOtqVaikPW09VxQy04FWPFGSxpkCxNk1EAGtcskyk8HVVHPkQ7y0
6M1V3RuINx0xu04t4r/OfmktLIzkisUMhTwq9aQZ03W1dcj8Uq41NWuUp5ZvzGxZ
TN6SxsS0ZXwllEgtYzoaiW3zfhSR7kcs+ZkLOqWwYQb3FBrfkdXAfm9YOAEOXyFW
L0mjmHT6Tn9u28klZaUCorThek1PRtBgH2rhWdXlMF7SxJ6O0ylt8xKE4sRec9A=
=4gXB
-----END PGP SIGNATURE-----

--okBLDKC1NTVRpHolO4chbiAqDNLXD2fGL--
