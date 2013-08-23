From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 01/10] net: etherdevice: add address inherit helper
Date: Sat, 24 Aug 2013 00:28:55 +0200
Message-ID: <87ppt4yrbs.fsf@nemi.mork.no>
References: <1377250513-3662-1-git-send-email-bjorn@mork.no>
	<1377250513-3662-2-git-send-email-bjorn@mork.no>
	<20130823122404.7aebb2c8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51834 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753610Ab3HWW3A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 18:29:00 -0400
In-Reply-To: <20130823122404.7aebb2c8@nehalam.linuxnetplumber.net> (Stephen
	Hemminger's message of "Fri, 23 Aug 2013 12:24:04 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:
> On Fri, 23 Aug 2013 11:35:04 +0200
> Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
>
>>  /**
>> + * eth_hw_addr_inherit - Copy dev_addr from another net_device
>> + * @dst: pointer to net_device to copy dev_addr to
>> + * @src: pointer to net_device to copy dev_addr from
>> + *
>> + * Copy the Ethernet address from one net_device to another along w=
ith
>> + * the addr_assign_type.
>> + */
>> +static inline int eth_hw_addr_inherit(struct net_device *dst,
>> +				      struct net_device *src)
>> +{
>> +	if (dst->addr_len !=3D src->addr_len)
>> +		return -EINVAL;
>> +
>> +	dst->addr_assign_type =3D src->addr_assign_type;
>> +	memcpy(dst->dev_addr, src->dev_addr, dst->addr_len);
>> +	return 0;
>> +}
>> +
>
> Since all the other code in this file assumes addr_len =3D=3D ETH_ALE=
N
> why does this code need to handle variable addresses. Trivial but
> then the memcpy is fixed size and can be optimized.

Didn't know that. I'll make that change in the next version.  Not that
optimization matters much here, but consistency is always good.


Bj=C3=B8rn
