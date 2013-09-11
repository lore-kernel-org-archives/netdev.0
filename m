From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: Do route updating for redirect in ndisc layer
Date: Wed, 11 Sep 2013 15:04:35 +0800
Message-ID: <52301603.7030906@cn.fujitsu.com>
References: <522D7444.20505@cn.fujitsu.com> <20130910225023.GB4794@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:37647 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751230Ab3IKHFf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:05:35 -0400
In-Reply-To: <20130910225023.GB4794@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B409=E6=9C=8811=E6=97=A5 06:50, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Mon, Sep 09, 2013 at 03:09:56PM +0800, Duan Jiong wrote:
>> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
>> index 5c71501..61fe8e5 100644
>> --- a/net/ipv6/tcp_ipv6.c
>> +++ b/net/ipv6/tcp_ipv6.c
>> @@ -382,14 +382,6 @@ static void tcp_v6_err(struct sk_buff *skb, str=
uct inet6_skb_parm *opt,
>> =20
>>  	np =3D inet6_sk(sk);
>> =20
>> -	if (type =3D=3D NDISC_REDIRECT) {
>> -		struct dst_entry *dst =3D __sk_dst_check(sk, np->dst_cookie);
>> -
>> -		if (dst)
>> -			dst->ops->redirect(dst, sk, skb);
>> -		goto out;
>> -	}
>> -
>=20
> You dropped the "goto out" here in case of an NDISC_REDIRECT, so this=
 sends an
> EPROTO further up the socket layer. Was this intended?
>=20

I'm sorry, i didn't notice the variable err was assigned to EPROTO.
I only thought that message should be sent to the socket layer, because
i found that in function sctp_v6_err().

In addition, the rfc 4443 said the Redirect Message is not the ICMPv6 E=
rror
Message, so i think we shouldn't call those err_handler function, in ot=
her
words we shouldn't call the icmpv6_notify().

How do you think of this?

> Also:
>=20
> In some _err() functions there is this check, e.g. ah6.c:
>=20
>     621         if (type !=3D ICMPV6_DEST_UNREACH &&
>     622             type !=3D ICMPV6_PKT_TOOBIG &&
>     623             type !=3D NDISC_REDIRECT)
>     624                 return;
>=20
> It could actually be adjusted now as we don't handle NDISC_REDIRECTs =
here any
> more. I don't see any side-effects down the code in these functions. =
We could
> also only just match on ICMPV6_PKT_TOOBIG. Can you confirm?
>=20

Yes, i agree this.=20

Thanks,
  Duan
