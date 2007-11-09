From: osprey67 <osprey67@yahoo.com>
Subject: Re: [PATCH 02/05] ipv6: RFC4214 Support (2)
Date: Fri, 09 Nov 2007 08:30:47 -0800
Message-ID: <47348B37.7050808@yahoo.com>
References: <47337483.3080309@yahoo.com> <20071109.082950.122508269.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.plus.mail.re1.yahoo.com ([69.147.102.72]:33172 "HELO
	smtp109.plus.mail.re1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751348AbXKIQiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 11:38:00 -0500
In-Reply-To: <20071109.082950.122508269.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <47337483.3080309@yahoo.com> (at Thu, 08 Nov 2007 12:41:39=
 -0800), osprey67 <osprey67@yahoo.com> says:
>=20
>> From: Fred L. Templin <osprey67@yahoo.com>
>>
>> This is experimental support for the Intra-Site Automatic
>> Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
>> the SIT module, and is configured using the unmodified
>> "ip" utility with device names beginning with: "isatap".
>>
>> The following diffs are specific to the Linux 2.6.24-rc2
>> kernel distribution.
>>
>> Signed-off-by: Fred L. Templin <osprey67@yahoo.com>
>=20
> Hmm...tabs are still mangled, and it's better to have your
> official address.  Anyway...

I have switched over to Thunderbird and POP mail. I submitted
the patches by cutting and pasting from a text file into the
mail message. Is there a way to stop it from clobbering tabs?

>> --- linux-2.6.24-rc2/include/net/addrconf.h.orig        2007-11-08 1=
2:06:17.000000000 -0800
>> +++ linux-2.6.24-rc2/include/net/addrconf.h     2007-11-08 08:27:24.=
000000000 -0800
>> @@ -241,6 +241,37 @@ static inline int ipv6_addr_is_ll_all_ro
>>                  addr->s6_addr32[3] =3D=3D htonl(0x00000002));
>>   }
>>
>> +#if defined(CONFIG_IPV6_ISATAP)
>> +static inline int ipv6_isatap_eui64(u8 *eui, __be32 addr)
>> +{
>> +
>> +       /* RFC3330 Special-Use IPv4 Addresses */
>> +       eui[0] =3D (((addr & htonl(0xFF000000)) =3D=3D htonl(0x00000=
000)) ||
>> +                 ((addr & htonl(0xFF000000)) =3D=3D htonl(0x0A00000=
0)) ||
>> +                 ((addr & htonl(0xFF000000)) =3D=3D htonl(0x0D00000=
0)) ||
>> +                 ((addr & htonl(0xFF000000)) =3D=3D htonl(0x1800000=
0)) ||
>> +                 ((addr & htonl(0xFF000000)) =3D=3D htonl(0x7F00000=
0)) ||
>> +                 ((addr & htonl(0xFFFF0000)) =3D=3D htonl(0xA9FE000=
0)) ||
>> +                 ((addr & htonl(0xFFF00000)) =3D=3D htonl(0xAC10000=
0)) ||
>> +                 ((addr & htonl(0xFFFFFF00)) =3D=3D htonl(0xC000020=
0)) ||
>> +                 ((addr & htonl(0xFFFFFF00)) =3D=3D htonl(0xC058630=
0)) ||
>> +                 ((addr & htonl(0xFFFF0000)) =3D=3D htonl(0xC0A8000=
0)) ||
>> +                 ((addr & htonl(0xFFFE0000)) =3D=3D htonl(0xC612000=
0)) ||
>> +                 ((addr & htonl(0xF0000000)) =3D=3D htonl(0xE000000=
0)) ||
>> +                 ((addr & htonl(0xF0000000)) =3D=3D htonl(0xF000000=
0))) ?
>> +                       0x00 : 0x02;
>> +
>> +       eui[1] =3D 0; eui[2] =3D 0x5E; eui[3] =3D 0xFE;
>> +       memcpy (eui+4, &addr, 4);
>> +       return 0;
>> +}
>> +
>=20
> Please put this function in net/ipv6/addrconf.c as addrconf_ifid_isat=
ap().
>=20
> Please use MULTICAST, LOCALNET etc. (and probaly introduce new macro
> for others).  IMHO, it's better to add a comment for each entry, e.g.=
,
> 	MULTICAST(addr) ||		/* 224.0.0.0/4 */
> instead of
> 	((addr & htonl(0xF0000000)) =3D=3D htonl(0xE0000000)) ||

OK - will do.

>> +static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
>> +{
>> +       return ((addr->s6_addr32[2] | htonl(0x02000000)) =3D=3D hton=
l(0x02005EFE));
>> +}
>> +#endif
>> +
>=20
> ipv6_addr_isatap(), maybe (to align with ipv6_addr_any() etc.).

Well, if you look in addrconf.h immediately above this the convention
seems to be to call it as "*_is_*" if it is testing an address and
to omit the "*_is_*" if it is setting an address. Since this is an
address test, maybe more consistent to keep the "*_is_*"?

Thanks - Fred
fred.l.templin@boeing.com

>=20
> --yoshfuji
>=20

