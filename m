From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [RFC v2 2/2] e100: Support RXFCS feature flag.
Date: Wed, 29 Jun 2011 16:33:51 +0200
Message-ID: <BANLkTikaJNa2+jbW6HWwc+tEE-ciNxvkLg@mail.gmail.com>
References: <1308942371-12748-1-git-send-email-greearb@candelatech.com>
 <1308942371-12748-3-git-send-email-greearb@candelatech.com>
 <BANLkTiknCV1HknVpEdK97yU8eJwaJ5Y5Ag@mail.gmail.com> <4E0B3510.2080202@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:45507 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756048Ab1F2OeM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 10:34:12 -0400
Received: by qwk3 with SMTP id 3so640806qwk.19
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2011 07:34:11 -0700 (PDT)
In-Reply-To: <4E0B3510.2080202@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 29 czerwca 2011 16:22 u=BFytkownik Ben Greear
<greearb@candelatech.com> napisa=B3:
> On 06/29/2011 04:37 AM, Micha=B3 Miros=B3aw wrote:
>> 2011/6/24<greearb@candelatech.com>:
>>> From: Ben Greear<greearb@candelatech.com>
>>>
>>> This allows e100 to be configured to append the
>>> Ethernet FCS to the skb.
>>>
>>> Useful for sniffing networks.
>>>
>>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>>> ---
>>> :100644 100644 c1352c6... 761f6f5... M =A0drivers/net/e100.c
>>> =A0drivers/net/e100.c | =A0 15 ++++++++++++---
>>> =A01 files changed, 12 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
>>> index c1352c6..761f6f5 100644
>>> --- a/drivers/net/e100.c
>>> +++ b/drivers/net/e100.c
>>> @@ -1089,6 +1089,7 @@ static void e100_configure(struct nic *nic, s=
truct
>>> cb *cb, struct sk_buff *skb)
>>> =A0{
>>> =A0 =A0 =A0 =A0struct config *config =3D&cb->u.config;
>>> =A0 =A0 =A0 =A0u8 *c =3D (u8 *)config;
>>> + =A0 =A0 =A0 struct net_device *netdev =3D nic->netdev;
>>>
>>> =A0 =A0 =A0 =A0cb->command =3D cpu_to_le16(cb_config);
>>>
>>> @@ -1132,6 +1133,9 @@ static void e100_configure(struct nic *nic, s=
truct
>>> cb *cb, struct sk_buff *skb)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0config->promiscuous_mode =3D 0x1; =A0=
 =A0 =A0 =A0 /* 1=3Don, 0=3Doff */
>>> =A0 =A0 =A0 =A0}
>>>
>>> + =A0 =A0 =A0 if (netdev->wanted_features& =A0NETIF_F_RXFCS)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 config->rx_crc_transfer =3D 0x1; =A0/=
* 1=3Dsave, 0=3Ddiscard */
>>> +
>> You should check netdev->features here.
> I thought 'features' was what the NIC could support, and wanted_featu=
res
> was what the NIC was currently configured to support? =A0I don't want
> to rx the CRC all the time, just when users enable it...

hw_features is what device could support, and features is what device
has currently turned on.

Best Regards,
Micha=B3 Miros=B3aw
