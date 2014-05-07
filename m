From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Is 3.18 patch "The tcp: TSO packets automatic sizing" will
 cause to Troughput drop when enable NO_HZ_IDEL or HIGH_RES_TIMERS ?
Date: Wed, 07 May 2014 08:45:52 -0700
Message-ID: <1399477552.15399.150.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CANHbGWs=oQBDVVZc8h5wX0WY+PRbQfCqiv5FrF1tH29QGiRndA@mail.gmail.com>
	 <1399393821.15399.12.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1399394474.15399.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CANHbGWttbfApi_K3HHFAFSa1=76fDmx2PP5bon1gzB1wOZXtAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: V JobNickname <workofv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35699 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932664AbaEGPp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 11:45:56 -0400
Received: by mail-pa0-f48.google.com with SMTP id rd3so1340689pab.21
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 08:45:55 -0700 (PDT)
In-Reply-To: <CANHbGWttbfApi_K3HHFAFSa1=76fDmx2PP5bon1gzB1wOZXtAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-07 at 22:27 +0800, V JobNickname wrote:
> 2014-05-07 0:41 GMT+08:00 Eric Dumazet <eric.dumazet@gmail.com>:
> > On Tue, 2014-05-06 at 09:30 -0700, Eric Dumazet wrote:
> >
> >> I cant see any effect for this patch explaining a 50% reduction in
> >> speed, unless a special qdisc setup maybe.
> >
> > Oh wait, a buggy driver could explain the problem.
> >
> > Some drivers really expected TX completion to happen as a side effect of
> > subsequent transmits.
> >
> > You'll have to give more details on the configuration you are using.
> >
> >
> >
> Does the "buggy driver" here mean the NIC driver or some higher level
> network stack driver?
> The xmit function of the used NIC driver is to stuff DMA channel, is
> there have "expected Tx completion" behavior in the driver's flow ?
> 
> The more detail:
> 
> 1. The platform's NIC is compilable with dwmac, use driver
> ethernet/stmicro/stmmac
>      some feature controls in plat_stmmacenet_data are set as
>         .phy_bus_name = "stmmac",
>         .bus_id = 0,
>         .phy_addr = -1, /*auto phy by pooling by mdio bus */
>         .has_gmac = 1,
>         .enh_desc = 0,
>         .tx_coe = 1,
>         .rx_coe = STMMAC_RX_COE_TYPE2,

Right, this driver seems to implement a 'coalescing tx strategy' using a
40ms timer.

Try to lower STMMAC_COAL_TX_TIMER ?
