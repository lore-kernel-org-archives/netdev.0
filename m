From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH 1/1 net-next] net/atm/signaling.c: replace
 current->state by  __set_current_state()
Date: Mon, 23 Feb 2015 12:50:25 -0500
Message-ID: <20150223125025.61a25b4a@thirdoffive.cmf.nrl.navy.mil>
References: <1424712667-11849-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Peter Zijlstra <peterz@infradead.org>, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424712667-11849-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of fixing code that never gets compiled/test, you could probably
just remove the #if WAIT_FOR_DAEMON code which would get rid of this
raw assignment.

See the #undef around line 268.

On Mon, 23 Feb 2015 18:31:07 +0100
Fabian Frederick <fabf@skynet.be> wrote:

> Use helper functions to access current->state.
> Direct assignments are prone to races and therefore buggy.
> 
> Thanks to Peter Zijlstra for the exact definition of the problem.
> 
> Suggested-By: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
>  net/atm/signaling.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/atm/signaling.c b/net/atm/signaling.c
> index 523bce7..0140832 100644
> --- a/net/atm/signaling.c
> +++ b/net/atm/signaling.c
> @@ -40,7 +40,7 @@ static void sigd_put_skb(struct sk_buff *skb)
>  		pr_debug("atmsvc: waiting for signaling daemon...\n");
>  		schedule();
>  	}
> -	current->state = TASK_RUNNING;
> +	__set_current_state(TASK_RUNNING);
>  	remove_wait_queue(&sigd_sleep, &wait);
>  #else
>  	if (!sigd) {
