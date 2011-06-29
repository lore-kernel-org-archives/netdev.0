From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC v2 2/2] e100: Support RXFCS feature flag.
Date: Wed, 29 Jun 2011 07:22:08 -0700
Message-ID: <4E0B3510.2080202@candelatech.com>
References: <1308942371-12748-1-git-send-email-greearb@candelatech.com> <1308942371-12748-3-git-send-email-greearb@candelatech.com> <BANLkTiknCV1HknVpEdK97yU8eJwaJ5Y5Ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35598 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755535Ab1F2OWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 10:22:15 -0400
In-Reply-To: <BANLkTiknCV1HknVpEdK97yU8eJwaJ5Y5Ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2011 04:37 AM, Micha=B3 Miros=B3aw wrote:
> 2011/6/24<greearb@candelatech.com>:
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This allows e100 to be configured to append the
>> Ethernet FCS to the skb.
>>
>> Useful for sniffing networks.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>> ---
>> :100644 100644 c1352c6... 761f6f5... M  drivers/net/e100.c
>>   drivers/net/e100.c |   15 ++++++++++++---
>>   1 files changed, 12 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
>> index c1352c6..761f6f5 100644
>> --- a/drivers/net/e100.c
>> +++ b/drivers/net/e100.c
>> @@ -1089,6 +1089,7 @@ static void e100_configure(struct nic *nic, st=
ruct cb *cb, struct sk_buff *skb)
>>   {
>>         struct config *config =3D&cb->u.config;
>>         u8 *c =3D (u8 *)config;
>> +       struct net_device *netdev =3D nic->netdev;
>>
>>         cb->command =3D cpu_to_le16(cb_config);
>>
>> @@ -1132,6 +1133,9 @@ static void e100_configure(struct nic *nic, st=
ruct cb *cb, struct sk_buff *skb)
>>                 config->promiscuous_mode =3D 0x1;         /* 1=3Don,=
 0=3Doff */
>>         }
>>
>> +       if (netdev->wanted_features&  NETIF_F_RXFCS)
>> +               config->rx_crc_transfer =3D 0x1;  /* 1=3Dsave, 0=3Dd=
iscard */
>> +
>
> You should check netdev->features here.

I thought 'features' was what the NIC could support, and wanted_feature=
s
was what the NIC was currently configured to support?  I don't want
to rx the CRC all the time, just when users enable it...

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
