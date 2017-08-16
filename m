From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dccp: defer ccid_hc_tx_delete() at dismantle time
Date: Wed, 16 Aug 2017 14:27:14 -0700 (PDT)
Message-ID: <20170816.142714.1364386866278233165.davem@davemloft.net>
References: <1502892195.4936.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerrit@erg.abdn.ac.uk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38642 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752154AbdHPV1P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 17:27:15 -0400
In-Reply-To: <1502892195.4936.111.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Aug 2017 07:03:15 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syszkaller team reported another problem in DCCP [1]
> 
> Problem here is that the structure holding RTO timer
> (ccid2_hc_tx_rto_expire() handler) is freed too soon.
> 
> We can not use del_timer_sync() to cancel the timer
> since this timer wants to grab socket lock (that would risk a dead lock)
> 
> Solution is to defer the freeing of memory when all references to
> the socket were released. Socket timers do own a reference, so this
> should fix the issue.
> 
> [1]
> ==================================================================
> BUG: KASAN: use-after-free in ccid2_hc_tx_rto_expire+0x51c/0x5c0 net/dccp/ccids/ccid2.c:144
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable, thanks.
