From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] veth: remove hardware checksum feature
Date: Wed, 07 Aug 2013 17:23:44 -0700
Message-ID: <5202E510.9060309@candelatech.com>
References: <51F15E50.8080208@guap.ru> <5202E153.4060202@candelatech.com> <1375920752.4004.71.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Vitaly E. Lavrov" <lve@guap.ru>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41488 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933288Ab3HHAXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 20:23:52 -0400
In-Reply-To: <1375920752.4004.71.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2013 05:12 PM, Eric Dumazet wrote:
> On Wed, 2013-08-07 at 17:07 -0700, Ben Greear wrote:
>> On 07/25/2013 10:20 AM, Vitaly E. Lavrov wrote:
>>> The network device VETH can't support the feature NETIF_F_HW_CSUM.
>>> All locally generated packets have invalid checksum.
>>> Wrong commit http://git.kernel.org/cgit/linux/kernel/git/torvalds/l=
inux.git/commit/?id=3D8093315a91340bca52549044975d8c7f673b28a1 ( kernel=
 3.9.0 )
>>>
>>> Workaround "ethtool -K vethX tx off"
>>>
>>> Possible patch:
>>>
>>> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
>>> index 177f911..3db97da 100644
>>> --- a/drivers/net/veth.c
>>> +++ b/drivers/net/veth.c
>>> @@ -254,7 +254,7 @@ static const struct net_device_ops veth_netdev_=
ops =3D {
>>>    };
>>>
>>>    #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_A=
LL_TSO |    \
>>> -                      NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_H=
IGHDMA | \
>>> +                      NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
>>>                          NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_=
CTAG_RX | \
>>>                          NETIF_F_HW_VLAN_STAG_TX | NETIF_F_HW_VLAN_=
STAG_RX )
>>
>> I see the same problem.
>>
>> My test case is a bit complicated, but the gist is that I have a VET=
H
>> pair, one with IP (veth1), one connected to a bridge-like-thing (vet=
h2).
>>
>> The UDP frames sent on veth1 appear on veth2, and when I sniff veth2=
,
>> the packets show broken checksum.  The work-around mentioned in Vita=
ly's
>> email above fixes the problem for me (I did not try the patch yet).
>>
>> Eric:  You responded originally that you needed more info.  If
>> my explanation above is not sufficient, please let me know what
>> you need...
>>
>
> tcpdump is known to display wrong checksums, its not a reason to disa=
ble
> tx checksums on our interfaces and kill performance.

I am receiving the packet into user space by reading veth2
using a packet socket, and then writing that packet out to eth6
(e100e).  As far as I can tell, it reads from veth2 with bad checksum
and then goes onto the wire with bad checksum.

>         -K     Don't  attempt to verify IP, TCP, or UDP checksums.  T=
his
> is useful for interfaces that perform some or all of those checksum
> calculation in hardware; other=E2=80=90
>                wise, all outgoing TCP checksums will be flagged as ba=
d.

Is it ever valid to *read* a packet with bad checksum though?  I though=
t
the bogus bad hw-checksum issue was only on the tx-side as far as sniff=
ing goes?

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
