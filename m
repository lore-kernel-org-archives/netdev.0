From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] sctp: Add check for the TSN field of the SHUTDOWN
 chunk
Date: Thu, 23 Oct 2008 01:00:31 -0700 (PDT)
Message-ID: <20081023.010031.119412816.davem@davemloft.net>
References: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
	<1224641327-11913-3-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	yjwei@cn.fujitsu.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38266
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751993AbYJWIAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 04:00:54 -0400
In-Reply-To: <1224641327-11913-3-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 21 Oct 2008 22:08:45 -0400

> If SHUTDOWN chunk is received Cumulative TSN Ack beyond the max tsn currently
> send, SHUTDOWN chunk be accepted and the association will be broken. New data
> is send, but after received SACK it will be drop because TSN in SACK is less
> than the Cumulative TSN, data will be retrans again and again even if correct
> SACK is received.
> 
> The packet sequence is like this:
> 
> Endpoint A                       Endpoint B       ULP
> (ESTABLISHED)                    (ESTABLISHED)
> 
>                <-----------      DATA (TSN=x-1)
> 
>                <-----------      DATA (TSN=x)
> 
>   SHUTDOWN     ----------->      (Now Cumulative TSN=x+1000)
>   (TSN=x+1000)
>                <-----------      DATA (TSN=x+1)
> 
>   SACK         ----------->      drop the SACK
>   (TSN=x+1)
>                <-----------      DATA (TSN=x+1)(retrans)
> 
> This patch fix this problem by terminating the association and respond to
> the sender with an ABORT.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
