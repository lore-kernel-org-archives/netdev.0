From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch net] sctp: use KMALLOC_MAX_SIZE instead of its own
 MAX_KMALLOC_SIZE
Date: Sun, 3 Mar 2013 22:52:26 -0500
Message-ID: <20130304035226.GA4273@neilslaptop.think-freely.org>
References: <1362364107-26908-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51954 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757316Ab3CDDws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Mar 2013 22:52:48 -0500
Content-Disposition: inline
In-Reply-To: <1362364107-26908-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 04, 2013 at 10:28:27AM +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> Don't definite its own MAX_KMALLOC_SIZE, use the one
> defined in mm.
> 
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Sridhar Samudrala <sri@us.ibm.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>

> ---
> diff --git a/net/sctp/ssnmap.c b/net/sctp/ssnmap.c
> index 442ad4e..825ea94 100644
> --- a/net/sctp/ssnmap.c
> +++ b/net/sctp/ssnmap.c
> @@ -41,8 +41,6 @@
>  #include <net/sctp/sctp.h>
>  #include <net/sctp/sm.h>
>  
> -#define MAX_KMALLOC_SIZE	131072
> -
>  static struct sctp_ssnmap *sctp_ssnmap_init(struct sctp_ssnmap *map, __u16 in,
>  					    __u16 out);
>  
> @@ -65,7 +63,7 @@ struct sctp_ssnmap *sctp_ssnmap_new(__u16 in, __u16 out,
>  	int size;
>  
>  	size = sctp_ssnmap_size(in, out);
> -	if (size <= MAX_KMALLOC_SIZE)
> +	if (size <= KMALLOC_MAX_SIZE)
>  		retval = kmalloc(size, gfp);
>  	else
>  		retval = (struct sctp_ssnmap *)
> @@ -82,7 +80,7 @@ struct sctp_ssnmap *sctp_ssnmap_new(__u16 in, __u16 out,
>  	return retval;
>  
>  fail_map:
> -	if (size <= MAX_KMALLOC_SIZE)
> +	if (size <= KMALLOC_MAX_SIZE)
>  		kfree(retval);
>  	else
>  		free_pages((unsigned long)retval, get_order(size));
> @@ -124,7 +122,7 @@ void sctp_ssnmap_free(struct sctp_ssnmap *map)
>  		int size;
>  
>  		size = sctp_ssnmap_size(map->in.len, map->out.len);
> -		if (size <= MAX_KMALLOC_SIZE)
> +		if (size <= KMALLOC_MAX_SIZE)
>  			kfree(map);
>  		else
>  			free_pages((unsigned long)map, get_order(size));
> 
