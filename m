From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH net-next] r8169: Add 64bit statistics
Date: Thu, 17 Nov 2011 18:59:57 +0800
Message-ID: <CABoNC83U2k=-6-BkJEyWBXfSnEbb-+K8CD1ffqhjA613Tk04tQ@mail.gmail.com>
References: <20111117064826.GA4429@Desktop-Junchang>
	<0a41dc06-15ab-4cf6-9bbd-3a1556993854@tahiti.vyatta.com>
	<CABoNC82RO2uvn9TfToAygEspUZnNrefXgO6SGpZoSAayCp3QiA@mail.gmail.com>
	<1321517516.3274.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org, romieu@fr.zoreil.com,
	nic swsd <nic_swsd@realtek.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:35046 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756543Ab1KQK76 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 05:59:58 -0500
Received: by vcbfk1 with SMTP id fk1so1501921vcb.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 02:59:57 -0800 (PST)
In-Reply-To: <1321517516.3274.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes, look at sky2.c for a template
>
> drivers/net/ethernet/marvell/sky2.c contains code like that
> (different syncp for rx/tx)
>
> TX path:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0u64_stats_update_begin(&sky2->tx_stats.syncp);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0++sky2->tx_stats.packets;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0sky2->tx_stats.bytes +=3D skb->len;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0u64_stats_update_end(&sky2->tx_stats.syncp);
>
>
> RX path:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u64_stats_update_begin(&sky2->rx_stats.syn=
cp);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sky2->rx_stats.packets +=3D packets;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sky2->rx_stats.bytes +=3D bytes;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u64_stats_update_end(&sky2->rx_stats.syncp=
);
>

Thanks, Eric.

I'm still confused about why we need two sync entries. Please correct
me if I'm wrong.

Take r8169 for example, All statistic entries are updated in
rtl8169_rx_interrupt() or rtl8169_tx_interrupt(). Those two functions
are called in rtl8169_poll().
As far as I know, rtl8169_poll() is protected by NAPI_STATE_SCHED bit
to run on a single core at one moment. So there is not compulsory to
use two sync entries.

One benefit from two sync is that readers can avoid many retries.

Thanks.
--=20
--Junchang
