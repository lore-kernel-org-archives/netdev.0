From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v2 11/20] net: packetengines: slight optimization
 of addr
Date: Sat, 28 Dec 2013 23:18:45 +0800
Message-ID: <52BEEBD5.1040301@gmail.com>
References: <52BE6D0D.9050301@huawei.com> <52BED8ED.2040908@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:60122 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754677Ab3L1Pa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 10:30:29 -0500
In-Reply-To: <52BED8ED.2040908@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/12/28 21:58, Sergei Shtylyov =E5=86=99=E9=81=93:
> Hello.
>=20
> On 28-12-2013 10:17, Ding Tianhong wrote:
>=20
>> Use possibly more efficient ether_addr_equal
>> to instead of memcmp.
>=20
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>   drivers/net/ethernet/packetengines/yellowfin.c |   12 ++++++------
>>   1 files changed, 6 insertions(+), 6 deletions(-)
>=20
>> diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/driver=
s/net/ethernet/packetengines/yellowfin.c
>> index d28593b..b83ac0e 100644
>> --- a/drivers/net/ethernet/packetengines/yellowfin.c
>> +++ b/drivers/net/ethernet/packetengines/yellowfin.c
>> @@ -1097,12 +1097,12 @@ static int yellowfin_rx(struct net_device *d=
ev)
>>               if (status2 & 0x80) dev->stats.rx_dropped++;
>>   #ifdef YF_PROTOTYPE        /* Support for prototype hardware errat=
a. */
>>           } else if ((yp->flags & HasMACAddrBug)  &&
>> -            memcmp(le32_to_cpu(yp->rx_ring_dma +
>> -                entry*sizeof(struct yellowfin_desc)),
>> -                dev->dev_addr, 6) !=3D 0 &&
>> -            memcmp(le32_to_cpu(yp->rx_ring_dma +
>> -                entry*sizeof(struct yellowfin_desc)),
>> -                "\377\377\377\377\377\377", 6) !=3D 0) {
>> +            !ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
>> +                              entry * sizeof(struct yellowfin_desc)=
),
>> +                              dev->dev_addr) &&
>=20
>    Previous line was aligned correctly, the above line should start u=
nder le32_to_cpu.
>=20
>> +            !ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
>> +                              entry * sizeof(struct yellowfin_desc)=
),
>=20
>    Start the continuation lines under 'yp', please.
>=20
>> +                              "\377\377\377\377\377\377")) {
>=20
>    This line should start under le32_to_cpu.
>=20
> WBR, Sergei
>=20

Hi sergei:
you mean this way?
	!ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
				      entry * sizeof(struct yellowfin_desc)),
			  dev->dev_addr) &&

	!ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
				      entry * sizeof(struct yellowfin_desc)),
			  "\377\377\377\377\377\377")) {

Regards
Ding

> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
