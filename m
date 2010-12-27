From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2] CAN: Use inode instead of kernel address for /proc
 file
Date: Mon, 27 Dec 2010 14:39:19 +0100
Message-ID: <4D189707.5000708@hartkopp.net>
References: <1293382493.9764.54.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:23090 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753777Ab0L0NjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Dec 2010 08:39:21 -0500
In-Reply-To: <1293382493.9764.54.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.12.2010 17:54, Dan Rosenberg wrote:
> Since the socket address is just being used as a unique identifier, its
> inode number is an alternative that does not leak potentially sensitive
> information.
> 
> CC-ing stable because MITRE has assigned CVE-2010-4565 to the issue.
> 
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
> Cc: stable <stable@kernel.org>

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Thanks Dan

> ---
>  net/can/bcm.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/can/bcm.c b/net/can/bcm.c
> index 6faa825..bc51b56 100644
> --- a/net/can/bcm.c
> +++ b/net/can/bcm.c
> @@ -125,7 +125,7 @@ struct bcm_sock {
>  	struct list_head tx_ops;
>  	unsigned long dropped_usr_msgs;
>  	struct proc_dir_entry *bcm_proc_read;
> -	char procname [20]; /* pointer printed in ASCII with \0 */
> +	char procname [32]; /* inode number in decimal with \0 */
>  };
>  
>  static inline struct bcm_sock *bcm_sk(const struct sock *sk)
> @@ -1521,7 +1521,7 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
>  
>  	if (proc_dir) {
>  		/* unique socket address as filename */
> -		sprintf(bo->procname, "%p", sock);
> +		sprintf(bo->procname, "%lu", sock_i_ino(sk));
>  		bo->bcm_proc_read = proc_create_data(bo->procname, 0644,
>  						     proc_dir,
>  						     &bcm_proc_fops, sk);
> 
> 
