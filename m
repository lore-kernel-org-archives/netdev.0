From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL net-next 04/17] ndisc: Introduce ndisc_fill_redirect_hdr_option().
Date: Thu, 20 Dec 2012 01:25:51 +0900
Message-ID: <50D1EA8F.7070504@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org> <50D04B4B.7060002@linux-ipv6.org> <87txrib6wa.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58455 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755681Ab2LSQZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 11:25:53 -0500
In-Reply-To: <87txrib6wa.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork wrote:
> YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> writes:
>=20
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> ---
>>  net/ipv6/ndisc.c |   21 +++++++++++++++------
>>  1 file changed, 15 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
>> index a181113..0a4f3a9 100644
>> --- a/net/ipv6/ndisc.c
>> +++ b/net/ipv6/ndisc.c
>> @@ -1332,6 +1332,19 @@ static void ndisc_redirect_rcv(struct sk_buff=
 *skb)
>>  	icmpv6_notify(skb, NDISC_REDIRECT, 0, 0);
>>  }
>> =20
>> +static u8 *ndisc_fill_redirect_hdr_option(u8 *opt, struct sk_buff *=
orig_skb,
>> +					  int rd_len)
>> +{
>> +	memset(opt, 0, 8);
>> +	*(opt++) =3D ND_OPT_REDIRECT_HDR;
>> +	*(opt++) =3D (rd_len >> 3);
>> +	opt +=3D 6;
>> +
>> +	memcpy(opt, ipv6_hdr(orig_skb), rd_len - 8);
>> +
>> +	return opt;
>> +}
>> +
>=20
> I realize that it doesn't currently matter, but the above modificatio=
n
> of "opt" looks like a bug-waiting-to-happen to me.
>=20
>>  void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr=
 *target)
>>  {
>>  	struct net_device *dev =3D skb->dev;
>> @@ -1461,12 +1474,8 @@ void ndisc_send_redirect(struct sk_buff *skb,=
 const struct in6_addr *target)
>>  	 *	build redirect option and copy skb over to the new packet.
>>  	 */
>> =20
>> -	memset(opt, 0, 8);
>> -	*(opt++) =3D ND_OPT_REDIRECT_HDR;
>> -	*(opt++) =3D (rd_len >> 3);
>> -	opt +=3D 6;
>> -
>> -	memcpy(opt, ipv6_hdr(skb), rd_len - 8);
>> +	if (rd_len)
>> +		opt =3D ndisc_fill_redirect_hdr_option(opt, skb, rd_len);
>=20
>=20
> I understand that opt isn't currently used after this, but if it ever=
 is
> then it is going to come as big a surprise that this implies opt +=3D=
 8;
>=20
> This was previously quite clear when the code was inline, but it beco=
mes
> problematic when it is factored out.

I understand your concern.  opt will be disappeared by following
changeset (12 of 17).

--yoshfuji
