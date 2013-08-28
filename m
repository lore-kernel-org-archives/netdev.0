From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 01/10] net: etherdevice: add address inherit helper
Date: Wed, 28 Aug 2013 09:17:00 +0200
Message-ID: <874naa2sk3.fsf@nemi.mork.no>
References: <1377250513-3662-2-git-send-email-bjorn@mork.no>
	<20130823122404.7aebb2c8@nehalam.linuxnetplumber.net>
	<87ppt4yrbs.fsf@nemi.mork.no>
	<20130827.143501.1692335946060457637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:59666 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753058Ab3H1HR0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 03:17:26 -0400
In-Reply-To: <20130827.143501.1692335946060457637.davem@davemloft.net> (David
	Miller's message of "Tue, 27 Aug 2013 14:35:01 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> Date: Sat, 24 Aug 2013 00:28:55 +0200
>
>> Stephen Hemminger <stephen@networkplumber.org> writes:
>>> On Fri, 23 Aug 2013 11:35:04 +0200
>>> Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
>>>
>>>>  /**
>>>> + * eth_hw_addr_inherit - Copy dev_addr from another net_device
>>>> + * @dst: pointer to net_device to copy dev_addr to
>>>> + * @src: pointer to net_device to copy dev_addr from
>>>> + *
>>>> + * Copy the Ethernet address from one net_device to another along=
 with
>>>> + * the addr_assign_type.
>>>> + */
>>>> +static inline int eth_hw_addr_inherit(struct net_device *dst,
>>>> +				      struct net_device *src)
>>>> +{
>>>> +	if (dst->addr_len !=3D src->addr_len)
>>>> +		return -EINVAL;
>>>> +
>>>> +	dst->addr_assign_type =3D src->addr_assign_type;
>>>> +	memcpy(dst->dev_addr, src->dev_addr, dst->addr_len);
>>>> +	return 0;
>>>> +}
>>>> +
>>>
>>> Since all the other code in this file assumes addr_len =3D=3D ETH_A=
LEN
>>> why does this code need to handle variable addresses. Trivial but
>>> then the memcpy is fixed size and can be optimized.
>>=20
>> Didn't know that. I'll make that change in the next version.  Not th=
at
>> optimization matters much here, but consistency is always good.
>
> You can bug check that addr_len ETH_ALEN if you want.

I don't think that is necessary. =20

> I realize that some drivers don't initialize it by this call point bu=
t
> that is arguably a bug.

Yes.  But I don't believe another test is going to make those drivers
work, so it's better to just drop it.


Bj=C3=B8rn
