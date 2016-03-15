From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] sctp: consolidate local_bh_disable/enable +
 spin_lock/unlock to _bh variant
Date: Tue, 15 Mar 2016 15:03:05 -0300
Message-ID: <20160315180305.GP31743@localhost.localdomain>
References: <1457866104-24342-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	wangweidong <wangweidong1@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1457866104-24342-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 13, 2016 at 11:48:24AM +0100, Nicholas Mc Guire wrote:
> local_bh_disable() + spin_lock() is equivalent to spin_lock_bh(), same for
> the unlock/enable case, so replace the calls by the appropriate wrappers.
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
> 
> net-next 3c8e43ba "sctp: remove macros sctp_spin_[un]lock" and
> net-next 79b91130 "sctp: remove macros sctp_local_bh_{disable|enable}"
> reverted scpt macros back to spin_lock/unlock and local_bh_disable/enable
> which can be consolidated to spin_lock_bh/spin_unlock_bh in this case.
> 
> Compile tested with: x86_64_defconfig + CONFIG_IP_SCTP=m
> 
> Patch is against linux-next (localversion-next is next-20160311)
> 
>  net/sctp/socket.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index b2dc8eb..f62feb0 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -7256,14 +7256,12 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
>  	/* Hook this new socket in to the bind_hash list. */
>  	head = &sctp_port_hashtable[sctp_phashfn(sock_net(oldsk),
>  						 inet_sk(oldsk)->inet_num)];
> -	local_bh_disable();
> -	spin_lock(&head->lock);
> +	spin_lock_bh(&head->lock);
>  	pp = sctp_sk(oldsk)->bind_hash;
>  	sk_add_bind_node(newsk, &pp->owner);
>  	sctp_sk(newsk)->bind_hash = pp;
>  	inet_sk(newsk)->inet_num = inet_sk(oldsk)->inet_num;
> -	spin_unlock(&head->lock);
> -	local_bh_enable();
> +	spin_unlock_bh(&head->lock);
>  
>  	/* Copy the bind_addr list from the original endpoint to the new
>  	 * endpoint so that we can handle restarts properly
> -- 
> 2.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
