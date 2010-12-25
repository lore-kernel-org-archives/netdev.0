From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] CAN: Use inode instead of kernel address for /proc file
Date: Sat, 25 Dec 2010 23:22:21 +0100
Message-ID: <4D166E9D.5080200@hartkopp.net>
References: <1293315371.9764.44.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:64921 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab0LYWWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 17:22:23 -0500
In-Reply-To: <1293315371.9764.44.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.12.2010 23:16, Dan Rosenberg wrote:
> Since the socket address is just being used as a unique identifier, its
> inode number is an alternative that does not leak potentially sensitive
> information.
> 
> CC-ing stable because MITRE has assigned CVE-2010-4565 to the issue.
> 
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
> Cc: stable <stable@kernel.org>

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Thanks Dan.

> ---
>  net/can/bcm.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/can/bcm.c b/net/can/bcm.c
> index 6faa825..5748901 100644
> --- a/net/can/bcm.c
> +++ b/net/can/bcm.c
> @@ -1520,8 +1520,8 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
>  	bo->bound = 1;
>  
>  	if (proc_dir) {
> -		/* unique socket address as filename */
> -		sprintf(bo->procname, "%p", sock);
> +		/* socket inode as filename */
> +		sprintf(bo->procname, "%lx", sock_i_ino(sk));
>  		bo->bcm_proc_read = proc_create_data(bo->procname, 0644,
>  						     proc_dir,
>  						     &bcm_proc_fops, sk);
> 

