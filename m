From: Joe Jin <joe.jin@oracle.com>
Subject: Re: [Xen-devel] [PATCH 1/1] xen-netfront: limit max queues number to
 online cpus
Date: Fri, 23 Oct 2015 15:19:32 +0800
Message-ID: <5629DF84.70201@oracle.com>
References: <5629846B.8000001@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
To: boris.ostrovsky@oracle.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45439 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbbJWHTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 03:19:40 -0400
In-Reply-To: <5629846B.8000001@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to take care sysfs too, please ignore this patch, I'll create
new one later for review and comment.

Thanks,
Joe
On 10/23/2015 08:50 AM, Joe Jin wrote:
> Should not allocate queues number more than online cpus.
> 
> Signed-off-by: Joe Jin <joe.jin@oracle.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/xen-netfront.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index f821a97..1eebd4e 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -2137,7 +2137,7 @@ static int __init netif_init(void)
>  	/* Allow as many queues as there are CPUs if user has not
>  	 * specified a value.
>  	 */
> -	if (xennet_max_queues == 0)
> +	if (xennet_max_queues == 0 || xennet_max_queues > num_online_cpus())
>  		xennet_max_queues = num_online_cpus();
>  
>  	return xenbus_register_frontend(&netfront_driver);
> 
