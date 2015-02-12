From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: Hold tp->lock before calling tg3_halt() from
 tg3_init_one()
Date: Wed, 11 Feb 2015 19:51:44 -0800 (PST)
Message-ID: <20150211.195144.1566555083391993799.davem@davemloft.net>
References: <54DC0140.6000406@ce.jp.nec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: prashant@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org
To: j-nomura@ce.jp.nec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754883AbbBLDom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 22:44:42 -0500
In-Reply-To: <54DC0140.6000406@ce.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Junichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 12 Feb 2015 01:26:24 +0000

> tg3_init_one() calls tg3_halt() without tp->lock despite its assumption
> and causes deadlock.
> If lockdep is enabled, a warning like this shows up before the stall:
> 
>   [ BUG: bad unlock balance detected! ]
>   3.19.0test #3 Tainted: G            E
>   -------------------------------------
>   insmod/369 is trying to release lock (&(&tp->lock)->rlock) at:
>   [<ffffffffa02d5a1d>] tg3_chip_reset+0x14d/0x780 [tg3]
>   but there are no more locks to release!
> 
> tg3_init_one() doesn't call tg3_halt() under normal situation but
> during kexec kdump I hit this problem.
> 
> Fixes: 932f19de ("tg3: Release tp->lock before invoking synchronize_irq()")
> Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>

Applied.
