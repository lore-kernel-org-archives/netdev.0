From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH v1] bpf: Set register type according to is_valid_access()
Date: Thu, 22 Sep 2016 21:53:06 +0200
Message-ID: <57E436A2.5070903@digikod.net>
References: <20160922183512.13576-1-mic@digikod.net>
 <57E433F0.90407@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="2pQAvHlg5fRrlFRvST5EnMV9lw0wBQ9nx"
Cc: Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Kees Cook <keescook@chromium.org>,
        Sargun Dhillon <sargun@sargun.me>, Tejun Heo <tj@kernel.org>,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57E433F0.90407@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--2pQAvHlg5fRrlFRvST5EnMV9lw0wBQ9nx
Content-Type: multipart/mixed; boundary="WohBJTeH4ihd9iALFbFJTlkcXWbgQov4j";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Daniel Borkmann <daniel@iogearbox.net>, linux-kernel@vger.kernel.org
Cc: Alexei Starovoitov <ast@kernel.org>, Andy Lutomirski
 <luto@amacapital.net>, Kees Cook <keescook@chromium.org>,
 Sargun Dhillon <sargun@sargun.me>, Tejun Heo <tj@kernel.org>,
 netdev@vger.kernel.org
Message-ID: <57E436A2.5070903@digikod.net>
Subject: Re: [PATCH v1] bpf: Set register type according to is_valid_access()
References: <20160922183512.13576-1-mic@digikod.net>
 <57E433F0.90407@iogearbox.net>
In-Reply-To: <57E433F0.90407@iogearbox.net>

--WohBJTeH4ihd9iALFbFJTlkcXWbgQov4j
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 22/09/2016 21:41, Daniel Borkmann wrote:
> On 09/22/2016 08:35 PM, Micka=C3=ABl Sala=C3=BCn wrote:
>> This fix a pointer leak when an unprivileged eBPF program read a point=
er
>> value from the context. Even if is_valid_access() returns a pointer
>> type, the eBPF verifier replace it with UNKNOWN_VALUE. The register
>> value containing an address is then allowed to leak. Moreover, this
>> prevented unprivileged eBPF programs to use functions with (legitimate=
)
>> pointer arguments.
>>
>> This bug is not an issue for now because the only unprivileged eBPF
>> program allowed is of type BPF_PROG_TYPE_SOCKET_FILTER and all the typ=
es
>> from its context are UNKNOWN_VALUE. However, this fix is important for=

>> future unprivileged eBPF program types which could use pointers in the=
ir
>> context.
>>
>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>> Fixes: 969bf05eb3ce ("bpf: direct packet access")
>> Cc: Alexei Starovoitov <ast@kernel.org>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: Kees Cook <keescook@chromium.org>
>> Acked-by: Sargun Dhillon <sargun@sargun.me>
>> ---
>>   kernel/bpf/verifier.c | 6 ++----
>>   1 file changed, 2 insertions(+), 4 deletions(-)
>>
>> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
>> index daea765d72e6..0698ccd67715 100644
>> --- a/kernel/bpf/verifier.c
>> +++ b/kernel/bpf/verifier.c
>> @@ -794,10 +794,8 @@ static int check_mem_access(struct verifier_env
>> *env, u32 regno, int off,
>>           }
>>           err =3D check_ctx_access(env, off, size, t, &reg_type);
>>           if (!err && t =3D=3D BPF_READ && value_regno >=3D 0) {
>> -            mark_reg_unknown_value(state->regs, value_regno);
>> -            if (env->allow_ptr_leaks)
>> -                /* note that reg.[id|off|range] =3D=3D 0 */
>> -                state->regs[value_regno].type =3D reg_type;
>> +            /* note that reg.[id|off|range] =3D=3D 0 */
>> +            state->regs[value_regno].type =3D reg_type;
>=20
> True that it's not an issue currently, since reg_type is only set for
> PTR_TO_PACKET/PTR_TO_PACKET_END in xdp and tc programs that can only be=

> loaded as privileged. So not an issue for BPF_PROG_TYPE_SOCKET_FILTER.
>=20
> One thing I don't quite follow is why you remove the
> mark_reg_unknown_value()
> as this also clears imm? I think this could result in an actual verifie=
r
> bug when it would reuse previous tracked imm value of that dst register=
?

Good catch, I missed the imm initialization. I'm going to send a new patc=
h.

>=20
>>           }
>>
>>       } else if (reg->type =3D=3D FRAME_PTR || reg->type =3D=3D PTR_TO=
_STACK) {
>>
>=20


--WohBJTeH4ihd9iALFbFJTlkcXWbgQov4j--

--2pQAvHlg5fRrlFRvST5EnMV9lw0wBQ9nx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX5DaiAAoJECLe/t9zvWqVfCwH/1YE24tyKlK5kXwyBmWgGkEg
iYbS0v5zz4xqS0dkZb4VJ/DD46a4hSHRzndjeCz+39XRoeRtcmATZY5Lpy8K0nZp
2nnSJzrxuYn2eEqqEY08uc8slXVNkztn8Da0W8AMKb4gQqywfPfmirmJCS//z1qZ
N2p9l51nijM+IzQtB3dbUjf7vjOziJ/6l3mbMWIfgz5V8o9yOjezTsiey2U7OSOM
Idt0ghhw6vxbXJJ5b4qU3VrfUKwnrzqRID+ElerRvLwYO4DtngWp/hhZi4EHdNmw
mvk3h6ojsCV2Y3bYQUXwmf1HFs1R3e4fxGOjH/ffqYc8jeBV6NnRxTPBqWWtYJA=
=xneR
-----END PGP SIGNATURE-----

--2pQAvHlg5fRrlFRvST5EnMV9lw0wBQ9nx--
