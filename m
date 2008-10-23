From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] sctp: Fix to handle SHUTDOWN in SHUTDOWN-PENDING
 state
Date: Thu, 23 Oct 2008 01:00:58 -0700 (PDT)
Message-ID: <20081023.010058.31323273.davem@davemloft.net>
References: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
	<1224641327-11913-4-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	yjwei@cn.fujitsu.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38269
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750999AbYJWIBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 04:01:21 -0400
In-Reply-To: <1224641327-11913-4-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 21 Oct 2008 22:08:46 -0400

> If SHUTDOWN is received in SHUTDOWN-PENDING state, enpoint should enter
> the SHUTDOWN-RECEIVED state and check the Cumulative TSN Ack field of
> the SHUTDOWN chunk (RFC 4960 Section 9.2). If the SHUTDOWN chunk can
> acknowledge all of the send DATA chunks, SHUTDOWN-ACK should be sent.
> 
> But now endpoint just silently discarded the SHUTDOWN chunk.
> 
> SHUTDOWN received in SHUTDOWN-PENDING state can happend when the last
> SACK is lost by network, or the SHUTDOWN chunk can acknowledge all of
> the received DATA chunks. The packet sequence(SACK lost) is like this:
> 
> Endpoint A                       Endpoint B       ULP
> (ESTABLISHED)                    (ESTABLISHED)
> 
>                <-----------      DATA
>                                              <--- shutdown
>                                  Enter SHUTDOWN-PENDING state
>   SACK         ----lost---->
> 
>   SHUTDOWN(*1) ------------>
> 
>                <-----------      SHUTDOWN-ACK
> 
>  (*1) silently discarded now.
> 
> This patch fix to handle SHUTDOWN in SHUTDOWN-PENDING state as the same
> as ESTABLISHED state.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
