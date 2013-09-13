From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH 10/11] ipv6: move route updating for redirect to ndisc
 layer
Date: Fri, 13 Sep 2013 09:38:39 +0800
Message-ID: <52326C9F.5070700@cn.fujitsu.com>
References: <52319A6E.6090503@cn.fujitsu.com> <52319CC5.10902@cn.fujitsu.com> <20130912220435.GC2101@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57926 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756243Ab3IMBjj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 21:39:39 -0400
In-Reply-To: <20130912220435.GC2101@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B409=E6=9C=8813=E6=97=A5 06:04, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Thu, Sep 12, 2013 at 06:51:49PM +0800, Duan Jiong wrote:
>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>
>> And when dealing with redirect message, the err shoud
>> be assigned to 0.
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>> ---
>>  net/ipv6/raw.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
>> index 58916bb..6138199 100644
>> --- a/net/ipv6/raw.c
>> +++ b/net/ipv6/raw.c
>> @@ -336,7 +336,7 @@ static void rawv6_err(struct sock *sk, struct sk=
_buff *skb,
>>  		harderr =3D (np->pmtudisc =3D=3D IPV6_PMTUDISC_DO);
>>  	}
>>  	if (type =3D=3D NDISC_REDIRECT)
>> -		ip6_sk_redirect(skb, sk);
>> +		err =3D 0;
>>  	if (np->recverr) {
>>  		u8 *payload =3D skb->data;
>>  		if (!inet->hdrincl)
>=20
> Hm, I don't like the cirumstance that we first call icmpv6_err_conver=
t at
> first and get back a bogus error value and later on convert it to som=
ething
> meaningful.
>=20
> Either:
> a) Don't call icmpv6_err_convert at all for redirects. Then we could
>    place a WARN_ON(type =3D=3D NDISC_REDIRECT) into this function to =
find future
>    missuse of this function with redirects or
>=20
> b) handle the update of the NDISC_REDIRECT error code directly in
>    icmpv6_err_convert.
>=20
> Also that you used the same headings for some commits shows that you =
could
> perhaps squash them into one patch.
>=20
> Otherwise I'm fine with the changes, thanks.
>=20

Thanks for you help, i will modify my patch.

Thanks,
  Duan
