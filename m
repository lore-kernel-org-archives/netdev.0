From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: avoid flushing statistics when doing a MTU
 change
Date: Mon, 30 Nov 2009 03:02:07 -0800
Message-ID: <C27F8246C663564A84BB7AB34397724218065B9852@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <4B13A321.8070909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Eric Dumazet'" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4603 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752010AbZK3LCM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 06:02:12 -0500
In-Reply-To: <4B13A321.8070909@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> Michael Chan a =E9crit :
> > Calling bnx2_get_stats() won't refresh the stats counters because
> > they are DMA'ed once a second.  There's an I/O to immediately DMA
> > the counters:
> >
> > REG_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd |
> >                                 BNX2_HC_COMMAND_STATS_NOW);
> > REG_RD(bp, BNX2_HC_COMMAND);
> >
> > We then need to add some delay to wait for the DMA to complete.
>
> Yes, but if you dont call bnx2_get_stats() netdev->stats will contain
> possibly very old values.
>
> At least, calling it will give one no more than second error.
>

OK I see.  We are also not saving the ethtool stats.  So perhaps the
more complete solution is to save the entire statistics block before
reset.

