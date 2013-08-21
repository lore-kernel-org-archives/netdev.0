From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH V2] ipv6: handle Redirect ICMP Message with no Redirected
 Header option
Date: Wed, 21 Aug 2013 10:12:25 +0800
Message-ID: <52142209.6030406@cn.fujitsu.com>
References: <52131725.6000409@cn.fujitsu.com> <20130820115020.GB3938@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:47237 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751427Ab3HUCNt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 22:13:49 -0400
In-Reply-To: <20130820115020.GB3938@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B408=E6=9C=8820=E6=97=A5 19:50, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Tue, Aug 20, 2013 at 03:13:41PM +0800, Duan Jiong wrote:
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -1178,6 +1178,28 @@ void ip6_redirect(struct sk_buff *skb, struct=
 net *net, int oif, u32 mark)
>>  }
>>  EXPORT_SYMBOL_GPL(ip6_redirect);
>> =20
>> +void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, i=
nt oif,
>> +			    u32 mark)
>> +{
>> +	const struct ipv6hdr *iph =3D (struct ipv6hdr *)skb_network_header=
(skb);
>=20
> Was there a problem with ipv6_hdr?
>=20
Actually ipv6_hdr is better, and i will modify it.
>> +	const struct rd_msg *msg =3D (struct rd_msg *)skb_transport_header=
(skb);
>> +	struct dst_entry *dst;
>> +	struct flowi6 fl6;
>> +
>> +	memset(&fl6, 0, sizeof(fl6));
>> +	fl6.flowi6_oif =3D oif;
>> +	fl6.flowi6_mark =3D mark;
>> +	fl6.flowi6_flags =3D 0;
>> +	fl6.daddr =3D msg->dest;
>> +	fl6.saddr =3D iph->daddr;
>> +
>> +	dst =3D ip6_route_output(net, NULL, &fl6);
>> +	if (!dst->error)
>> +		rt6_do_redirect(dst, NULL, skb);
>> +	dst_release(dst);
>> +}
>> +EXPORT_SYMBOL_GPL(ip6_redirect_no_header);
>> +
>>  void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk)
>>  {
>>  	ip6_redirect(skb, sock_net(sk), sk->sk_bound_dev_if, sk->sk_mark);
>=20
> Introducing a new function here is the right thing. Maybe you could h=
ave
> a look how these redirects could be fed to raw sockets, too?
>=20
Because of no Redirected Header option, so we don't have enough
information to find out the related raw socket. So, there is no need
to deal with that condition.

Thanks,
  Duan=20
