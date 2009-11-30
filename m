From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2: avoid flushing statistics when doing a MTU change
Date: Mon, 30 Nov 2009 11:49:05 +0100
Message-ID: <4B13A321.8070909@gmail.com>
References: <C27F8246C663564A84BB7AB34397724218065B9851@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51717 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbZK3KtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 05:49:03 -0500
In-Reply-To: <C27F8246C663564A84BB7AB34397724218065B9851@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan a =E9crit :
> Eric Dumazet wrote:
>=20
>> leitao@linux.vnet.ibm.com a =E9crit :
>>> Actually when bnx2 changes the interface's MTU size, it resets
>>> the chip and consequently flushes the interface statistics.
>>> This patch saves the statistics in a temporary space in order to
>>> maintain the statistics correct after the chip reset.
>>>
>>> Signed-off-by: Breno Leitao<leitao@linux.vnet.ibm.com>
>>
>>
>>>     return net_stats;
>>>  }
>>> @@ -6989,6 +7004,11 @@ bnx2_change_ring_size(struct bnx2
>> *bp, u32 rx, u32 tx)
>>>  {
>>>     if (netif_running(bp->dev)) {
>>>             bnx2_netif_stop(bp);
>> I wonder if you need to renew this stats before copying them ?
>>  (eg calling bnx2_get_stats())
>=20
> Calling bnx2_get_stats() won't refresh the stats counters because
> they are DMA'ed once a second.  There's an I/O to immediately DMA
> the counters:
>=20
> REG_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd |
>                                 BNX2_HC_COMMAND_STATS_NOW);
> REG_RD(bp, BNX2_HC_COMMAND);
>=20
> We then need to add some delay to wait for the DMA to complete.

Yes, but if you dont call bnx2_get_stats() netdev->stats will contain
possibly very old values.

At least, calling it will give one no more than second error.

