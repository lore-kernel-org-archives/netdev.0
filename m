From: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>
Subject: Re: [PATCH] net: eth: altera: fix napi poll_list corruption
Date: Thu, 3 Sep 2015 15:01:02 +0900
Message-ID: <20150903.150102.391475245.nemoto@toshiba-tops.co.jp>
References: <20150902.112500.2176991714061589322.davem@davemloft.net>
	<20150903.095257.116214212.nemoto@toshiba-tops.co.jp>
	<20150902.223254.456957929929322205.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <vbridger@opensource.altera.com>, <netdev@vger.kernel.org>,
	<eric.dumazet@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from topsowa.toshiba-tops.co.jp ([61.200.21.19]:11311 "EHLO
	TPSSRV64.toshiba-tops.co.jp" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750752AbbICGBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 02:01:23 -0400
In-Reply-To: <20150902.223254.456957929929322205.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Sep 2015 22:32:54 -0700, David Miller <davem@davemloft.net> wrote:
>> I think napi_gro_flush() can be called with irq enabled, so moving the
>> spin_lock_irqsave() just before the __napi_complete() (or moving the
>> __napi_complete() just after the spin_lock_irqsave()) would be better,
>> right?
> 
> It should work, yes.

Thank you.  But I agree with Eric's last comment ("Calling
napi_gro_flush() and __napi_complete() looks error prone."), and found
that napi_complete_done() also checks NAPI_STATE_NPSVC to support
NETPOLL.  These checks looks somewhat redundant but I like simple way
unless it is really critical to performance.

So, please take original fix as is.
