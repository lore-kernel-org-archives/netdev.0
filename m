From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix a lockdep splat
Date: Wed, 22 Sep 2010 13:33:09 -0700 (PDT)
Message-ID: <20100922.133309.246524529.davem@davemloft.net>
References: <201009220858.o8M8w8s3094017@www262.sakura.ne.jp>
	<1285176935.2639.453.camel@edumazet-laptop>
	<1285184088.2380.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1285184088.2380.18.camel@edumazet-laptop>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 Sep 2010 21:34:48 +0200

> [PATCH] net: fix a lockdep splat
> 
> We have for each socket :
 ...
> This patch makes sure inet_csk_listen_stop() uses following lock order :
> 
> write_lock_bh(&sk->sk_callback_lock)
> spin_lock(&sk->sk_slock)
> ...
> spin_unlock(&sk->sk_slock)
> write_unlock_bh(&sk->sk_callback_lock)
> 
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

FWIW, this looks fine to me.

I'll apply it when we have positive testing feedback from
Tetsuo.

Thanks.
