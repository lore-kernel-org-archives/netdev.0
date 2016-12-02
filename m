From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: thunderx: Fix transmit queue timeout
 issue
Date: Fri, 02 Dec 2016 13:33:11 -0500 (EST)
Message-ID: <20161202.133311.494383963195952738.davem@davemloft.net>
References: <1480596868-17693-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com
To: sunil.kovvuri@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480596868-17693-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: sunil.kovvuri@gmail.com
Date: Thu,  1 Dec 2016 18:24:28 +0530

> From: Sunil Goutham <sgoutham@cavium.com>
> 
> Transmit queue timeout issue is seen in two cases
> - Due to a race condition btw setting stop_queue at xmit()
>   and checking for stopped_queue in NAPI poll routine, at times
>   transmission from a SQ comes to a halt. This is fixed
>   by using barriers and also added a check for SQ free descriptors,
>   incase SQ is stopped and there are only CQE_RX i.e no CQE_TX.
> - Contrary to an assumption, a HW errata where HW doesn't stop transmission
>   even though there are not enough CQEs available for a CQE_TX is
>   not fixed in T88 pass 2.x. This results in a Qset error with
>   'CQ_WR_FULL' stalling transmission. This is fixed by adjusting
>   RXQ's  RED levels for CQ level such that there is always enough
>   space left for CQE_TXs.
> 
> Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
> ---
> v2: As suggested by David, replaced netif_tx_start_queue with 
>     netif_tx_wake_queue.

Applied, thanks.
