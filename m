From: Sujith Manoharan <sujith@msujith.org>
Subject: Re: TCP performance regression
Date: Mon, 11 Nov 2013 13:49:27 +0530
Message-ID: <21120.37647.979237.40802@gargle.gargle.HOWL>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>
	<1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<21120.29720.673157.151074@gargle.gargle.HOWL>
	<1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s72.web-hosting.com ([198.187.29.21]:55219 "EHLO
	s72.web-hosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794Ab3KKIX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 03:23:56 -0500
In-Reply-To: <1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Hmm... apparently ath9k uses :
> 
> #define ATH_AMPDU_LIMIT_MAX        (64 * 1024 - 1)

This is the maximum AMPDU size, specified in the
802.11 standard.

> And mentions a 4ms time frame :
> 
> max_4ms_framelen = ATH_AMPDU_LIMIT_MAX;

The 4ms limitation is a FCC limitation and is used
for regulatory compliance.

> So prior to "tcp: TSQ can use a dynamic limit", the ~128KB bytes TCP
> could queue per TCP socket on qdisc/NIC would happen to please ath9k

Ok.

> ath9k can set rts_aggr_limit to 8*1024 :
> 
>  if (AR_SREV_9160_10_OR_LATER(ah) || AR_SREV_9100(ah))
>   pCap->rts_aggr_limit = ATH_AMPDU_LIMIT_MAX; 
>  else
>   pCap->rts_aggr_limit = (8 * 1024);

The RTS limit is required for some old chips which had HW bugs and
the above code is a workaround.

> A timer would be definitely needed, and it should be rather small (1 or
> 2 ms)
> 
> If TCP socket is application limited, it seems ath9k can delay the last
> block by a too long time.

I am not really clear on how this regression can be fixed in the driver
since the majority of the transmission/aggregation logic is present in the
TX completion path.

Sujith
