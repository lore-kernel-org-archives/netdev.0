From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v2 0/6] slight optimization of addr compare for
 some modules
Date: Mon, 16 Dec 2013 22:53:40 +0800
Message-ID: <52AF13F4.5040409@gmail.com>
References: <52AEB8B3.5010405@huawei.com> <1387205111.18217.7.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:37210 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755Ab3LPPFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 10:05:10 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so5429862pdi.24
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 07:05:09 -0800 (PST)
In-Reply-To: <1387205111.18217.7.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/12/16 22:45, Joe Perches =E5=86=99=E9=81=93:
> On Mon, 2013-12-16 at 16:24 +0800, Ding Tianhong wrote:
>> Joe Perches add ether_addr_equal_unaligned to test if
>> possibly unaligned to u16 Ethernet addresses are equal.
>>
>> If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set, this uses
>> the slightly faster generic routine ether_addr_equal,
>> otherwise this uses memcmp.
>>
>> So I replace memcmp with ether_addr_equal_unaligned in some place
>> for slight optimization.
>=20
> Hi.
>=20
> These seem like sensible cleanups, thanks, but
> my name doesn't need to go into the commit log
> multiple times like this.
>=20
> I suggest something like:
>=20
> Use the recently added and possibly more efficient
> ether_addr_equal_unaligned.
>=20
> Are you intending to do more of these?
>=20
> $ git grep -E "\bmemcmp\s*\([^,]*,[^,]*,\s*(ETH_ALEN|6)\s*\)" * | wc =
-l
> 299
>=20
> Perhaps the majority of these should use ether_addr_equal
> or ether_addr_equal_unaligned.
>=20
>=20

yes, it is a juge work to review the whole places and I think it should=
 be
finished by several times, maybe start from this patchset.

I will modify the changelog and simplify it. Thanks.

Regards
Ding


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
