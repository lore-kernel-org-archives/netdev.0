From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v2 20/20] net: caif: slight optimization of addr
 compare
Date: Sat, 28 Dec 2013 23:02:08 +0800
Message-ID: <52BEE7F0.1070506@gmail.com>
References: <52BE6D50.9000308@huawei.com> <1388213953.24123.2.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	=?UTF-8?B?U2p1ciBCcsOmbmRlbGFuZA==?=
	<sjur.brandeland@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388213953.24123.2.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2013/12/28 14:59, Joe Perches =E5=86=99=E9=81=93:
> On Sat, 2013-12-28 at 14:18 +0800, Ding Tianhong wrote:
>> Use possibly more efficient ether_addr_equal
>> to instead of memcmp.
>=20
> This may be a distinction without difference, but
> is a CAIF seghead also an ethernet address?
>=20

NO=EF=BC=8Cthis is a coincidence, the CAIF seghead is 6 bytes too,
So from a logical point of view, maybe a new function with
suitable name will be more reasonable here, but the name of
ether_addr_equal is not correctly here.:)

thanks

Regards
Ding

>> diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
> []
>> @@ -79,7 +79,7 @@ static struct cfpkt *rfm_append(struct cfrfml *rfm=
l, char *seghead,
> []
>>  	/* Verify correct header */
>> -	if (memcmp(seghead, rfml->seghead, 6) !=3D 0)
>> +	if (!ether_addr_equal(seghead, rfml->seghead))
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
