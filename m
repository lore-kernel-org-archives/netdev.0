From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/dccp: fix use after free in tw_timer_handler()
Date: Tue, 21 Feb 2017 13:23:51 -0500 (EST)
Message-ID: <20170221.132351.1602433391866901233.davem@davemloft.net>
References: <CACT4Y+aZrpZ3JevLrg5i=nTzBAcVhKX9qmajyW5b-+xExwrCHg@mail.gmail.com>
        <20170221112740.661-1-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org, dvyukov@google.com,
        edumazet@google.com, xiyou.wangcong@gmail.com,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        syzkaller@googlegroups.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: aryabinin@virtuozzo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56378 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753871AbdBUSXy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 13:23:54 -0500
In-Reply-To: <20170221112740.661-1-aryabinin@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Date: Tue, 21 Feb 2017 14:27:40 +0300

> DCCP doesn't purge timewait sockets on network namespace shutdown.
> So, after net namespace destroyed we could still have an active timer
> which will trigger use after free in tw_timer_handler():
 ...
> Add .exit_batch hook to dccp_v4_ops()/dccp_v6_ops() which will purge
> timewait sockets on net namespace destruction and prevent above issue.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Applied and queued up for -stable, thanks.
