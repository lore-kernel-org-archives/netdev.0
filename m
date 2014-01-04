From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH RESEND] netfilter: remove unused variable
Date: Sat, 04 Jan 2014 01:29:13 +0100
Message-ID: <xa1ta9fck2sm.fsf@mina86.com>
References: <1388554039-28452-1-git-send-email-mina86@mina86.com> <20140103231146.GA23904@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140103231146.GA23904@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Sat, Jan 04 2014, Pablo Neira Ayuso wrote:
> On Wed, Jan 01, 2014 at 06:27:19AM +0100, Michal Nazarewicz wrote:
>> The nfmsg variable is not used (except in sizeof operator which does
>> not care about its value) between the first and second time it is
>> assigned the value.  Furthermore, nlmsg_data has no side effects, so
>> the assignment can be safely removed.
>
> Applied with minor glitch, see below.

Thanks.

> Thanks.
>
>> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
>> Cc: Patrick McHardy <kaber@trash.net>
>> ---
>>  net/netfilter/nf_tables_api.c | 1 -
>>  1 file changed, 1 deletion(-)
>>=20
>> diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api=
.c
>> index f93b7d0..9c56adc 100644
>> --- a/net/netfilter/nf_tables_api.c
>> +++ b/net/netfilter/nf_tables_api.c
>> @@ -2521,7 +2521,6 @@ static int nf_tables_dump_set(struct sk_buff *skb,=
 struct netlink_callback *cb)
>>  	u32 portid, seq;
>>  	int event, err;
>>=20=20
>> -	nfmsg =3D nlmsg_data(cb->nlh);
>>  	err =3D nlmsg_parse(cb->nlh, sizeof(*nfmsg), nla, NFTA_SET_ELEM_LIST_M=
AX,
>
> mangled this patch to use sizeof(struct nfgenmsg) instead. That change
> is not required from the semantic point of view, of course, but for
> readability reasons I think it's better not to refer to a variable
> that is not used in that context.

Works for me, and=20

	err =3D nlmsg_parse(cb->nlh, sizeof(*nlmsg_data(cb->nlh)), nla,
			  NFTA_SET_ELEM_LIST_MAX, nft_set_elem_list_policy);

would probably be an overkill. ;)

>>  	if (err < 0)
>> --=20
>> 1.8.4

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJSx1XZAAoJECBgQBJQdR/00qcP/izw4odv34p50gZEW8zsBC8L
kRAywMQ88mLEFSHfMInfKgZQ9qKnk5wr5pH5hDLKQLTFvjuXuXCYozh6OG3R7ZYx
DWcXY+tPgrmZRZ1MCj/87dKiP2i5dFgLlxAn60Fk+BtgB+kAldmd5lbMEdsaAJ73
33CxZmP7G1FcCK1LXXWZTfoDmdhDy/mU4gYSimS43970EYvXFukEUNfU3VKNYDsV
76v0uNvY/EQ2GZwBT5qG8YySKAeEvcaFsSKextzeDxu7Q8yz3cGL3GZIqnmFIRQh
svgA3f3X+C1Ab0tv9tc4rd1hkFZzoZLqL3THqfc65zklLGsU+muwuqb8EDpmmiQR
0xHbnxlNU7mAKzXTX2H7oYkMmFwHVjWEgR4F9sWQvcbmfuUTknJ79mpo93eFH1V/
beR/jIvMZxhtVZ+nbIogZEPWJH6JPVam6GC//988KbysTGsqLzzM80fTcakExgol
Ua+jnaUPjr4AW+2rRGGJIw5JfKyofQ4m0etrb4HMP+WFVytmLYRaI1byq35S0ViC
bchKe5W72RbV860I70kUc3T+QTUYd3n+PD9TUDlEDLMeae2WHQMt0Zq8I3cqjg3/
+IJphuIvPuGOkhiiF7soJag1oYQCDy8mlMGghxnOYEZSFUwxBZBuJFb2jx0g5rB5
rEL7ui40/ER6PAhO3VpX
=Yorb
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--
