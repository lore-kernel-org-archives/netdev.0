From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: handle Redirect ICMP Message with no Redirected
 Header option
Date: Tue, 20 Aug 2013 10:00:06 +0800
Message-ID: <5212CDA6.4070509@cn.fujitsu.com>
References: <5211F97B.4090209@cn.fujitsu.com> <52126B54.4080603@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:33380 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751254Ab3HTCAa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 22:00:30 -0400
In-Reply-To: <52126B54.4080603@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2013=C4=EA08=D4=C220=C8=D5 03:00, Sergei Shtylyov =D0=B4=B5=C0:
> Hello.
>=20
> On 08/19/2013 02:54 PM, Duan Jiong wrote:
>=20
>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>=20
>> rfc 4861 says the Redirected Header option is optional, so
>> the kernel should not drop the Redirect Message that has no
>> Redirected Header option. In this patch, the function
>> ip6_redirect_no_header() is introduced to deal with that
>> condition.
>=20
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> [...]
>=20
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index b70f897..9934b87 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -1178,6 +1178,27 @@ void ip6_redirect(struct sk_buff *skb, struct=
 net *net, int oif, u32 mark)
>>   }
>>   EXPORT_SYMBOL_GPL(ip6_redirect);
>>  =20
>> +void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, i=
nt oif, u32 mark)
>> +{
>> +	const struct ipv6hdr *iph =3D (struct ipv6hdr *) skb_network_heade=
r(skb);
>> +	struct rd_msg *msg =3D (struct rd_msg *)skb_transport_header(skb);
>=20
>    Be consistent please: either put space after a typecast or not.
>=20
Thanks for you help, i will apply it in next version.

Thanks,
  Duan
