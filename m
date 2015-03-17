From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] inet: Clean up inet_csk_wait_for_connect() vs.
 might_sleep()
Date: Tue, 17 Mar 2015 08:35:01 +0100
Message-ID: <20150317073501.GP2896@worktop.programming.kicks-ass.net>
References: <1426533564.11398.229.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426533564.11398.229.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 16, 2015 at 12:19:24PM -0700, Eric Dumazet wrote:
> 
> In commit 26cabd31259ba43f68026ce3f62b78094124333f
> Peter added a sched_annotate_sleep() in sk_wait_event()
> 
> Is the following patch needed as well ?

Yes this is fine.

If we had indeed gone through the schedule and got woken we'd have had
TASK_RUNNING here, also when we retry the loop the prepare_to_wait call
will (re)set the TASK_INTERRUPTIBLE state.

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/inet_connection_sock.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index 14d02ea905b6..3e44b9b0b78e 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -268,6 +268,7 @@ static int inet_csk_wait_for_connect(struct sock *sk, long timeo)
>  		release_sock(sk);
>  		if (reqsk_queue_empty(&icsk->icsk_accept_queue))
>  			timeo = schedule_timeout(timeo);
> +		sched_annotate_sleep();
>  		lock_sock(sk);
>  		err = 0;
>  		if (!reqsk_queue_empty(&icsk->icsk_accept_queue))
> 
> 
> 
