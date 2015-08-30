From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4_en: Fix IPv6 csum calculation
Date: Sat, 29 Aug 2015 23:18:46 -0700
Message-ID: <CAJ3xEMhAJ+p2qG4oeYe4kpGnzRPj30F886nuSyTjNSuiN1u4qw@mail.gmail.com>
References: <1440790107-24268-1-git-send-email-clsoto@linux.vnet.ibm.com>
	<1440791217.11525.141.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: clsoto@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, brking@linux.vnet.ibm.com,
	Amir Vadai <amirv@mellanox.com>,
	Muhammad Mahajna <muhammadm@mellanox.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:36661 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbbH3GSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2015 02:18:47 -0400
Received: by oibi18 with SMTP id i18so44327895oib.3
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 23:18:46 -0700 (PDT)
In-Reply-To: <1440791217.11525.141.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 28, 2015 at 12:46 PM, Joe Perches <joe@perches.com> wrote:
> On Fri, 2015-08-28 at 14:28 -0500, clsoto@linux.vnet.ibm.com wrote:
>> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>>
>> Seeing this message with mlx4_eni with IPv6: hw csum failure
>>
>> Changing IPv6 csum calculation to be based on OFED 2.4 code.
>> When calculate IPv6 csum based also on source and destination
>> addresses.
> []
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> []
>> +static __wsum csum_ipv6_magic_nofold(const struct in6_addr *saddr,
>> +                                  const struct in6_addr *daddr,
>> +                                  __u32 len, unsigned short proto)
>> +{
>> +     __wsum res = 0;
>> +
>> +     res = csum_add(res, saddr->in6_u.u6_addr32[0]);
>> +     res = csum_add(res, saddr->in6_u.u6_addr32[1]);
>> +     res = csum_add(res, saddr->in6_u.u6_addr32[2]);
>> +     res = csum_add(res, saddr->in6_u.u6_addr32[3]);
>> +     res = csum_add(res, daddr->in6_u.u6_addr32[0]);
>> +     res = csum_add(res, daddr->in6_u.u6_addr32[1]);
>> +     res = csum_add(res, daddr->in6_u.u6_addr32[2]);
>> +     res = csum_add(res, daddr->in6_u.u6_addr32[3]);
>> +     res = csum_add(res, len);
>> +     res = csum_add(res, htonl(proto));
>
> You should try running sparse on this code.


Yep, if I remember correct, the patch is still under internal review
with making sparse/smatch happy on it being a pending comment.


Or.
