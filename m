From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/dccp: fix use after free in tw_timer_handler()
Date: Wed, 22 Feb 2017 16:15:38 -0500 (EST)
Message-ID: <20170222.161538.2214724719402158538.davem@davemloft.net>
References: <20170221112740.661-1-aryabinin@virtuozzo.com>
        <20170222093527.19698-1-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, edumazet@google.com, acme@kernel.org,
        dccp@vger.kernel.org, dvyukov@google.com, xiyou.wangcong@gmail.com,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        syzkaller@googlegroups.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: aryabinin@virtuozzo.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170222093527.19698-1-aryabinin@virtuozzo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Date: Wed, 22 Feb 2017 12:35:27 +0300

> DCCP doesn't purge timewait sockets on network namespace shutdown.
> So, after net namespace destroyed we could still have an active timer
> which will trigger use after free in tw_timer_handler():
 ...
> Add .exit_batch hook to dccp_v4_ops()/dccp_v6_ops() which will purge
> timewait sockets on net namespace destruction and prevent above issue.
> 
> Fixes: f2bf415cfed7 ("mib: add net to NET_ADD_STATS_BH")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied and queued up for -sable, thanks.
