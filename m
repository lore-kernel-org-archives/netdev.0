From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL net-next 04/17] ndisc: Introduce ndisc_fill_redirect_hdr_option().
Date: Thu, 20 Dec 2012 02:27:35 +0900
Message-ID: <50D1F907.30407@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org> <50D04B4B.7060002@linux-ipv6.org> <87txrib6wa.fsf@nemi.mork.no> <50D1EA8F.7070504@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58521 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750922Ab2LSR1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 12:27:36 -0500
In-Reply-To: <50D1EA8F.7070504@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2012=E5=B9=B412=E6=9C=8820=E6=97=A5 01:25), YOSHIFUJI Hideaki wrote:
> Bj=C3=B8rn Mork wrote:
>> YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> writes:

>>> +static u8 *ndisc_fill_redirect_hdr_option(u8 *opt, struct sk_buff =
*orig_skb,
>>> +					  int rd_len)
>>> +{
>>> +	memset(opt, 0, 8);
>>> +	*(opt++) =3D ND_OPT_REDIRECT_HDR;
>>> +	*(opt++) =3D (rd_len >> 3);
>>> +	opt +=3D 6;
>>> +
>>> +	memcpy(opt, ipv6_hdr(orig_skb), rd_len - 8);
>>> +
>>> +	return opt;
>>> +}
:
>> I understand that opt isn't currently used after this, but if it eve=
r is
>> then it is going to come as big a surprise that this implies opt +=3D=
 8;
>>
>> This was previously quite clear when the code was inline, but it bec=
omes
>> problematic when it is factored out.
>=20
> I understand your concern.  opt will be disappeared by following
> changeset (12 of 17).

Argh, I now notice return value was not quite right; it should
return opt + rd_len - 8.

=46ixed in my local tree.  Thanks.

--yoshfuji
