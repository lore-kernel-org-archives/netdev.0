From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/2] vhost: remove the possible fruitless search on iotlb
 prefetch
Date: Mon, 21 Aug 2017 22:45:58 +0300
Message-ID: <20170821223039-mutt-send-email-mst@kernel.org>
References: <20170819064114.27219-1-den@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Koichiro Den <den@klaipeden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40400 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753877AbdHUTp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 15:45:59 -0400
Content-Disposition: inline
In-Reply-To: <20170819064114.27219-1-den@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 19, 2017 at 03:41:14PM +0900, Koichiro Den wrote:
> Signed-off-by: Koichiro Den <den@klaipeden.com>
> ---
>  drivers/vhost/vhost.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index e4613a3c362d..93e909afc1c3 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -1184,7 +1184,7 @@ static int iotlb_access_ok(struct vhost_virtqueue *vq,
>  	while (len > s) {
>  		node = vhost_umem_interval_tree_iter_first(&umem->umem_tree,
>  							   addr,
> -							   addr + len - 1);
> +							   addr + len - s - 1);
>  		if (node == NULL || node->start > addr) {
>  			vhost_iotlb_miss(vq, addr, access);
>  			return false;

This works but it probably makes sense to just refactor the code to make end of
range a variable. I posted a patch like this, pls take a look.

> -- 
> 2.9.4
> 
