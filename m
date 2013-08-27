From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/10] net: etherdevice: add address inherit
 helper
Date: Tue, 27 Aug 2013 14:35:01 -0400 (EDT)
Message-ID: <20130827.143501.1692335946060457637.davem@davemloft.net>
References: <1377250513-3662-2-git-send-email-bjorn@mork.no>
	<20130823122404.7aebb2c8@nehalam.linuxnetplumber.net>
	<87ppt4yrbs.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188Ab3H0SfF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 14:35:05 -0400
In-Reply-To: <87ppt4yrbs.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Sat, 24 Aug 2013 00:28:55 +0200

> Stephen Hemminger <stephen@networkplumber.org> writes:
>> On Fri, 23 Aug 2013 11:35:04 +0200
>> Bj=F8rn Mork <bjorn@mork.no> wrote:
>>
>>>  /**
>>> + * eth_hw_addr_inherit - Copy dev_addr from another net_device
>>> + * @dst: pointer to net_device to copy dev_addr to
>>> + * @src: pointer to net_device to copy dev_addr from
>>> + *
>>> + * Copy the Ethernet address from one net_device to another along =
with
>>> + * the addr_assign_type.
>>> + */
>>> +static inline int eth_hw_addr_inherit(struct net_device *dst,
>>> +				      struct net_device *src)
>>> +{
>>> +	if (dst->addr_len !=3D src->addr_len)
>>> +		return -EINVAL;
>>> +
>>> +	dst->addr_assign_type =3D src->addr_assign_type;
>>> +	memcpy(dst->dev_addr, src->dev_addr, dst->addr_len);
>>> +	return 0;
>>> +}
>>> +
>>
>> Since all the other code in this file assumes addr_len =3D=3D ETH_AL=
EN
>> why does this code need to handle variable addresses. Trivial but
>> then the memcpy is fixed size and can be optimized.
>=20
> Didn't know that. I'll make that change in the next version.  Not tha=
t
> optimization matters much here, but consistency is always good.

You can bug check that addr_len ETH_ALEN if you want.

I realize that some drivers don't initialize it by this call point but
that is arguably a bug.
