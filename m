From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [Xen-devel] BUG in xennet_make_frags with paged skb data
Date: Fri, 07 Nov 2014 13:28:33 +0100
Message-ID: <545CBAF1.4020207@canonical.com>
References: <20141106214940.GD44162@ubuntu-hedt>	 <545C9013.1090406@linaro.org> <1415359320.13896.105.camel@edumazet-glaptop2.roam.corp.google.com> <545CB7FF.8080003@canonical.com> <545CB92E.9050106@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="0ViuMnpe8U2G0Vr4XJacPpStuwjAKOr1S"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@linaro.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <545CB92E.9050106@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0ViuMnpe8U2G0Vr4XJacPpStuwjAKOr1S
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 07.11.2014 13:21, Zoltan Kiss wrote:
>=20
>=20
> On 07/11/14 12:15, Stefan Bader wrote:
>> On 07.11.2014 12:22, Eric Dumazet wrote:
>>> On Fri, 2014-11-07 at 09:25 +0000, Zoltan Kiss wrote:
>>>
>>> Please do not top post.
>>>
>>>> Hi,
>>>>
>>>> AFAIK in this scenario your skb frag is wrong. The page pointer shou=
ld
>>>> point to the original compound page (not a member of it), and offset=

>>>> should be set accordingly.
>>>> For example, if your compound page is 16K (4 page), then the page
>>>> pointer should point to the first page, and if the data starts at th=
e
>>>> 3rd page, then offset should be >8K
>>>
>>> This is not accurate.
>>>
>>> This BUG_ON() is wrong.
>>>
>>> It should instead be :
>>>
>>> BUG_ON(len + offset > PAGE_SIZE<<compound_order(compound_head(page)))=
;
>>
>> would that not have to be
>>
>> BUG_ON((page-compound_head(page)*PAGE_SIZE)+offset+len >
>> PAGE_SIZE<<compound_order(compound_head(page)));
>=20
> There should be a parentheses around "page-compound_head(page)".

*sigh* before submitting anything I'll have to make sure I run it past th=
e
compiler at least. I never manager to type the beast without some error.

But you got the drift...

>>
>> since offset is adjusted to start from the tail page in that case.
>>>
>>> splice() code can generate such cases.
>>>
>>>
>>
>>



--0ViuMnpe8U2G0Vr4XJacPpStuwjAKOr1S
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJUXLrxAAoJEOhnXe7L7s6jWHkQALuMGqlxHCK1CKo30aofmUP9
hSqbVSEoqL8ahwPovgbA7aNsPfGgpoy1LM0xw1f/1nFWaGaN1YpMoS9MFqYOWK7n
SYl9sNztzG14uyQtGFyzLHhDkwCopkDqeDPYwcPbHN0knQfvZaTs47pR4Rgy6+Q+
bzvBN1aOe2wl1CC1h0Lbd8zkiXH29tGVJqgcWKnEo6Dwr/7SElujLCjXsAdm77AV
jdvdl2jEz6X2K4aXuHyUFkUtZ1DKkoHDP+RPNDxS9qyuS7UrjCMWf8n8Q0ieCWnl
0JLOA5mD79jj74md1N49XOieQMMivv/vjaJ9WrAN6u1SNpjM28ieqcXz85Yu9WXC
vQ2EkxEEWMJ7rN+Cqhk1kkFjKwL5ZEytlmtAFJhkoJbqn9Xyz+bUjG/Xsizyu+rK
JFgDYGqCd4iUl/JON4gPlk9Cclw2zeFb5yAD0rTv6tLakI3iJhnkP5z91cYPTICS
qZF0zWfhJQkgtZPKCeilTT8zWtrfpeNMK8awWUL9EAPzQ64LeJEgV9P7vo4mQNfG
XPGAbb/Rv4SKAsqTy7DYFNCnT0gEO/5Vr2LBD4/LXLtzpW9Lc1ZKzLs5IfYsYdGj
Jh6kIcAm4wWekaZqX61TKIjfwFVZ5buuZoZssmIKAtqsvxQGD+TcCgp601biRGP/
tcJMgLiZQiHGn6BCvZJl
=FOiu
-----END PGP SIGNATURE-----

--0ViuMnpe8U2G0Vr4XJacPpStuwjAKOr1S--
