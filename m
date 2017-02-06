From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v1 7/7] bpf: Always test unprivileged programs
Date: Mon, 6 Feb 2017 20:24:02 +0100
Message-ID: <c943cdc9-03ee-8a7c-c04f-7e33cb4d7561@digikod.net>
References: <20170205231428.23846-1-mic@digikod.net>
 <20170205231428.23846-7-mic@digikod.net> <58989FA0.7000906@fb.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="OSttKIiKoUqjn6ph6Klu5IxfXvMPxO8NV"
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
        Shuah Khan <shuah@kernel.org>,
        Arnaldo Carvalho de Melo <acme@infradead.org>
To: Alexei Starovoitov <ast@fb.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58989FA0.7000906@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--OSttKIiKoUqjn6ph6Klu5IxfXvMPxO8NV
Content-Type: multipart/mixed; boundary="dxNR28vkgqG05oDVUM46vHCuaNlMixncc";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Alexei Starovoitov <ast@fb.com>, linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
 Shuah Khan <shuah@kernel.org>, Arnaldo Carvalho de Melo <acme@infradead.org>
Message-ID: <c943cdc9-03ee-8a7c-c04f-7e33cb4d7561@digikod.net>
Subject: Re: [PATCH net-next v1 7/7] bpf: Always test unprivileged programs
References: <20170205231428.23846-1-mic@digikod.net>
 <20170205231428.23846-7-mic@digikod.net> <58989FA0.7000906@fb.com>
In-Reply-To: <58989FA0.7000906@fb.com>

--dxNR28vkgqG05oDVUM46vHCuaNlMixncc
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 06/02/2017 17:09, Alexei Starovoitov wrote:
> On 2/5/17 3:14 PM, Micka=C3=ABl Sala=C3=BCn wrote:
>> -        if (unpriv && test->prog_type)
>> -            continue;
>> +        if (!test->prog_type) {
>> +            if (!unpriv)
>> +                set_admin(false);
>> +            printf("#%d/u %s ", i, test->descr);
>> +            do_test_single(test, true, &passes, &errors);
>> +            if (!unpriv)
>> +                set_admin(true);
>> +        }
>>
>> -        printf("#%d %s ", i, test->descr);
>> -        do_test_single(test, unpriv, &passes, &errors);
>> +        if (!unpriv) {
>> +            printf("#%d/p %s ", i, test->descr);
>> +            do_test_single(test, false, &passes, &errors);
>> +        }
>=20
> great idea.
> Acked-by: Alexei Starovoitov <ast@kernel.org>
>=20
> as far as other patches.. we need to figure out how to avoid conflicts
> between net-next and Arnaldo's tree where Joe's patches went.

A merge between this series and Arnaldo's tree works fine. The only
dependency is between patches 6 and 7.

>=20
> Mickael,
> can you see some way of splitting the patch set between trees?
> Like above test_verfier.c improvement needs to go into net-next.
> The rest can go via perf
>=20
>=20

OK, I'll send a first series with the patches from 1 to 5 for the perf
tree and a second series with the 6th and 7th patches (touching
tools/testing/selftests/bpf only) to net-next.


--dxNR28vkgqG05oDVUM46vHCuaNlMixncc--

--OSttKIiKoUqjn6ph6Klu5IxfXvMPxO8NV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAliYzVIACgkQIt7+33O9
apUgOQf8CLpQe3S9jZSJPDDZ2Dh617mgteq1cJ0tTxKMpAfIs+LxvamPYFLftNqM
Q4WlhULWSKCY8fA8GkqhCBEYnYysLf5IuFgfrGCrJvCAm69SHrebsutvl4l+Xm1P
d6mxVDKvRaI9hdmqktC9qTiK42KvDomn3NKMJdPQ0OJu028fBbbnxwOXaV4rtwjU
S83tT12bpu0chKTx5070cu5gAK6f3yttqbVtcAn8I38A4S+urZqfk4g145AXmhP7
cU7oh7Jkh7ni1oyeTs2Z4pEi3KOz7uXfpjPyXjHy5Oqduzpf07mki9oY5l8xrxEE
sMsqio21NKRezmfrAcg7bkiOxa4euQ==
=XnL0
-----END PGP SIGNATURE-----

--OSttKIiKoUqjn6ph6Klu5IxfXvMPxO8NV--
