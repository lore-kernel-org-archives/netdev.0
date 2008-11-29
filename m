From: David Miller <davem@davemloft.net>
Subject: Re: cxgb3: Fix sparse warning and micro-optimize is_pure_response()
Date: Fri, 28 Nov 2008 21:55:48 -0800 (PST)
Message-ID: <20081128.215548.201883857.davem@davemloft.net>
References: <ada3ahbccdk.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, jeff@garzik.org, netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750748AbYK2Fzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 00:55:48 -0500
In-Reply-To: <ada3ahbccdk.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Fri, 28 Nov 2008 21:47:03 -0800

> The function is_pure_response() does "ntohl(var) & const" and then
> essentially just tests whether the result is 0 or not; this can be done
> more efficiently by computing "var & htonl(const)" instead and doing the
> byte swap at compile time instead of run time.
> 
> This change slightly shrinks the compiled code; eg on x86-64 we save a
> couple of bswapl instructions:
> 
> add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-8 (-8)
> function                                     old     new   delta
> t3_sge_intr_msix_napi                        544     536      -8
> 
> and this also has the pleasant side effect of fixing a sparse warning:
> 
>     drivers/net/cxgb3/sge.c:2313:15: warning: restricted degrades to integer
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>

Applied, thanks Roland.
