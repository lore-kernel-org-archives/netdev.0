From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH net-next] r8169: Add 64bit statistics
Date: Thu, 17 Nov 2011 15:39:05 +0800
Message-ID: <CABoNC81psapa0-Nog5+nDff7PgQszC7mTQPwHUeDAFjHTemdYA@mail.gmail.com>
References: <20111117064826.GA4429@Desktop-Junchang>
	<1321514484.3274.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, nic_swsd@realtek.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:46751 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744Ab1KQHjG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 02:39:06 -0500
Received: by vcbfk1 with SMTP id fk1so1350271vcb.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 23:39:05 -0800 (PST)
In-Reply-To: <1321514484.3274.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2011 at 3:21 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 17 novembre 2011 =C3=A0 14:48 +0800, Junchang Wang a =C3=A9c=
rit :
>> Switch to use ndo_get_stats64 to get 64bit statistics.
>> Per cpu data is used to avoid lock operations.
>>
>>
>> Signed-off-by: Junchang Wang <junchangwang@gmail.com>
>> ---
>> =C2=A0drivers/net/ethernet/realtek/r8169.c | =C2=A0113 +++++++++++++=
+++++++++++++++------
>> =C2=A01 files changed, 93 insertions(+), 20 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethe=
rnet/realtek/r8169.c
>> index cdf66d6..0165646 100644
>> --- a/drivers/net/ethernet/realtek/r8169.c
>> +++ b/drivers/net/ethernet/realtek/r8169.c
>> @@ -670,11 +670,31 @@ struct rtl8169_counters {
>> =C2=A0 =C2=A0 =C2=A0 __le16 =C2=A0tx_underun;
>> =C2=A0};
>>
>> +struct rtl8169_pcpu_stats {
>> + =C2=A0 =C2=A0 u64 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 rx_packets;
>> + =C2=A0 =C2=A0 u64 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 rx_bytes;
>> + =C2=A0 =C2=A0 u64 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 tx_packets;
>> + =C2=A0 =C2=A0 u64 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 tx_bytes;
>> + =C2=A0 =C2=A0 struct u64_stats_sync =C2=A0 syncp;
>> + =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0* The following variables are updated
>> + =C2=A0 =C2=A0 =C2=A0* without syncp protection.
>> + =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rx_=
dropped;
>> + =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tx_=
dropped;
>> + =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rx_=
length_errors;
>> + =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rx_=
errors;
>> + =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rx_=
crc_errors;
>> + =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rx_=
fifo_errors;
>> + =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rx_=
missed_errors;
>> +};
>> +
>
> Thats overkill. Dont copy what have been done for virtual devices
> (loopback, tunnels, ...)
>
> RX and TX path are serialized (only one cpu can fly at one moment)
>
Thanks. I'll submit a new version.



--=20
--Junchang
