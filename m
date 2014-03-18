From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/9] rcu: Replace rcu_assign_pointer(x, NULL) with
 RCU_INIT_POINTER(x, NULL) in drivers/net/macvtap.c
Date: Tue, 18 Mar 2014 16:29:35 -0700
Message-ID: <20140318232935.GC4420@linux.vnet.ibm.com>
References: <cover.1395182132.git.monamagarwal123@gmail.com>
 <a526cbfdba8a9a3380b685d34b4ee7ce52163d57.1395182132.git.monamagarwal123@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eddie.wai@broadcom.com
To: Monam Agarwal <monamagarwal123@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a526cbfdba8a9a3380b685d34b4ee7ce52163d57.1395182132.git.monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 19, 2014 at 04:14:31AM +0530, Monam Agarwal wrote:
> Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> ---
>  drivers/net/macvtap.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 1b7082d..7c88d13 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -145,8 +145,8 @@ static void macvtap_put_queue(struct macvtap_queue *q)
>  	if (vlan) {
>  		int index = get_slot(vlan, q);
> 
> -		rcu_assign_pointer(vlan->taps[index], NULL);
> -		rcu_assign_pointer(q->vlan, NULL);
> +		RCU_INIT_POINTER(vlan->taps[index], NULL);
> +		RCU_INIT_POINTER(q->vlan, NULL);
>  		sock_put(&q->sk);
>  		--vlan->numvtaps;
>  	}
> @@ -223,8 +223,8 @@ static void macvtap_del_queues(struct net_device *dev)
>  					      lockdep_is_held(&macvtap_lock));
>  		if (q) {
>  			qlist[j++] = q;
> -			rcu_assign_pointer(vlan->taps[i], NULL);
> -			rcu_assign_pointer(q->vlan, NULL);
> +			RCU_INIT_POINTER(vlan->taps[i], NULL);
> +			RCU_INIT_POINTER(q->vlan, NULL);
>  			vlan->numvtaps--;
>  		}
>  	}
> -- 
> 1.7.9.5
> 
