From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: Re: [Intel-wired-lan] [PATCH v2] ixgbe: on recv increment rx.ring->stats.yields
Date: Fri, 25 Dec 2015 19:26:12 +0300
Message-ID: <567D6E24.3030302@virtuozzo.com>
References: <566AD3F5.9050502@cogentembedded.com> <1449842714-10284-1-git-send-email-ptikhomirov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <devel@openvz.org>
To: <intel-wired-lan@lists.osuosl.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:37510 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbbLYQ0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2015 11:26:25 -0500
In-Reply-To: <1449842714-10284-1-git-send-email-ptikhomirov@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, please, let me know if I need to fix something else here.

On 12/11/2015 05:05 PM, Pavel Tikhomirov wrote:
> It seem to be non intentionaly changed to tx in
> commit adc810900a70 ("ixgbe: Refactor busy poll socket code to address
> multiple issues")
>
> Lock is taken from ixgbe_low_latency_recv, and there under this
> lock we use ixgbe_clean_rx_irq so it looks wrong for me to increment
> tx counter.
>
> Yield stats can be shown through ethtool:
> ethtool -S enp129s0 | grep yield
>
> v2: follow commit citing style
>
> Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
> ---
>   drivers/net/ethernet/intel/ixgbe/ixgbe.h | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> index 1d21745..7656d46 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> @@ -451,7 +451,7 @@ static inline bool ixgbe_qv_lock_poll(struct ixgbe_q_vector *q_vector)
>   				IXGBE_QV_STATE_POLL);
>   #ifdef BP_EXTENDED_STATS
>   	if (rc != IXGBE_QV_STATE_IDLE)
> -		q_vector->tx.ring->stats.yields++;
> +		q_vector->rx.ring->stats.yields++;
>   #endif
>   	return rc == IXGBE_QV_STATE_IDLE;
>   }
>

-- 
Best regards, Tikhomirov Pavel
Software Developer, Virtuozzo.
