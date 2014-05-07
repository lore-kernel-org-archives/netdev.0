From: V JobNickname <workofv@gmail.com>
Subject: Re: Is 3.18 patch "The tcp: TSO packets automatic sizing" will cause
 to Troughput drop when enable NO_HZ_IDEL or HIGH_RES_TIMERS ?
Date: Thu, 8 May 2014 00:18:32 +0800
Message-ID: <CANHbGWuiKAO=kufFYNVn6y+75Zk68X1FWD45uj0+k-hGmoDqkw@mail.gmail.com>
References: <CANHbGWs=oQBDVVZc8h5wX0WY+PRbQfCqiv5FrF1tH29QGiRndA@mail.gmail.com>
	<1399393821.15399.12.camel@edumazet-glaptop2.roam.corp.google.com>
	<1399394474.15399.22.camel@edumazet-glaptop2.roam.corp.google.com>
	<CANHbGWttbfApi_K3HHFAFSa1=76fDmx2PP5bon1gzB1wOZXtAw@mail.gmail.com>
	<1399477552.15399.150.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:63260 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbaEGQSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 12:18:33 -0400
Received: by mail-ie0-f170.google.com with SMTP id rd18so1258797iec.1
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 09:18:32 -0700 (PDT)
In-Reply-To: <1399477552.15399.150.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Try to lower
#define STMMAC_COAL_TX_TIMER    10000
or
#define STMMAC_TX_FRAMES    0 (this will casue to skip coalescing path)
can't solve the issue.

2014-05-07 23:45 GMT+08:00 Eric Dumazet <eric.dumazet@gmail.com>:
> On Wed, 2014-05-07 at 22:27 +0800, V JobNickname wrote:
>> 2014-05-07 0:41 GMT+08:00 Eric Dumazet <eric.dumazet@gmail.com>:
>> > On Tue, 2014-05-06 at 09:30 -0700, Eric Dumazet wrote:
>> >
>> >> I cant see any effect for this patch explaining a 50% reduction in
>> >> speed, unless a special qdisc setup maybe.
>> >
>> > Oh wait, a buggy driver could explain the problem.
>> >
>> > Some drivers really expected TX completion to happen as a side effect of
>> > subsequent transmits.
>> >
>> > You'll have to give more details on the configuration you are using.
>> >
>> >
>> >
>> Does the "buggy driver" here mean the NIC driver or some higher level
>> network stack driver?
>> The xmit function of the used NIC driver is to stuff DMA channel, is
>> there have "expected Tx completion" behavior in the driver's flow ?
>>
>> The more detail:
>>
>> 1. The platform's NIC is compilable with dwmac, use driver
>> ethernet/stmicro/stmmac
>>      some feature controls in plat_stmmacenet_data are set as
>>         .phy_bus_name = "stmmac",
>>         .bus_id = 0,
>>         .phy_addr = -1, /*auto phy by pooling by mdio bus */
>>         .has_gmac = 1,
>>         .enh_desc = 0,
>>         .tx_coe = 1,
>>         .rx_coe = STMMAC_RX_COE_TYPE2,
>
> Right, this driver seems to implement a 'coalescing tx strategy' using a
> 40ms timer.
>
> Try to lower STMMAC_COAL_TX_TIMER ?
>
>
>
