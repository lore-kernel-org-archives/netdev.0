From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCHv6 iptables]Interface group match
Date: Thu, 29 Nov 2007 17:23:59 +0100
Message-ID: <474EE79F.2000409@balabit.hu>
References: <11955644701165-git-send-email-panther@balabit.hu> <1195564470928-git-send-email-panther@balabit.hu> <11955644702451-git-send-email-panther@balabit.hu> <11955644701536-git-send-email-panther@balabit.hu> <11955644702194-git-send-email-panther@balabit.hu> <20071123133933.GA31396@innominate.com> <474EB585.30407@balabit.hu> <474EE5C6.9070500@trash.net>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lutz Jaenicke <ljaenicke@innominate.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <474EE5C6.9070500@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy =EDrta:
> Laszlo Attila Toth wrote:
>> Lutz Jaenicke =EDrta:
>>> On Tue, Nov 20, 2007 at 02:14:28PM +0100, Laszlo Attila Toth wrote:
>>>> Interface group values can be checked on both input and output=20
>>>> interfaces
>>>> with optional mask.
>>>
>>>> Index: extensions/libxt_ifgroup.c
>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>> --- extensions/libxt_ifgroup.c    (revision 0)
>>>> +++ extensions/libxt_ifgroup.c    (revision 0)
>>>
>>>> +        info->in_group =3D strtoul(optarg, &end, 0);
>>>
>>> This is somewhat inconsistent with the iproute patch which targets
>>> specific groups (with names).
>>> Should iptables be allowed to read "/etc/iproute2/rt_ifgroup"?
>>
>> It would be good but cannot be used if a mask is set and only values=
=20
>> less than 256 can be used with names.
>=20
>=20
> Why 256? I can see no such limitation. For masks you could
> simply allow to define masks in rt_ifgroup too and use
> name/name or simply name/0xmask.


256 because it is the size of a static array (and I don't want allocate=
=20
too much memory when other arrays such as the routing table names also=20
have this size). In the current version I posted some minutes ago=20
0..2^32-1  can be used.

The syntax "name/0xmask" is simply too strange for me.

>=20
>>> There is no standard API like getservbyname()...
>>
>> The code of iproute2 should be copied. If Patrick says it is ok,  I'=
ll=20
>> write this part.
>=20
>=20
> Of course. Please put the tab part somewhere common, I always
> wanted to have named firewall marks shared with ip and tc
> and I believe Balazs wanted that too :)

Ok. Yes, he wants :)


--=20
Attila
-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
