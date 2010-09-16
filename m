From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] vhost-net: fix range checking in mrg bufs case
Date: Thu, 16 Sep 2010 02:12:45 -0400 (EDT)
Message-ID: <1191794336.2270351284617565643.JavaMail.root@zmail05.collab.prod.int.phx2.redhat.com>
References: <20100914131552.GA1937@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:42263 "EHLO
	mx01.colomx.prod.int.phx2.redhat.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751240Ab0IPGMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 02:12:53 -0400
In-Reply-To: <20100914131552.GA1937@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested-by: Jason Wang <jasowang@redhat.com>

----- "Michael S. Tsirkin" <mst@redhat.com> wrote:

> In mergeable buffer case, we use headcount, log_num
> and seg as indexes in same-size arrays, and
> we know that headcount <= seg and
> log_num equals either 0 or seg.
> 
> Therefore, the right thing to do is range-check seg,
> not headcount as we do now: these will be different
> if guest chains s/g descriptors (this does not
> happen now, but we can not trust the guest).
> 
> Long term, we should add BUG_ON checks to verify
> two other indexes are what we think they should be.
> 
> Reported-by: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> Dave, I'll queue this on my tree, no need to bother.
> 
>  drivers/vhost/net.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 6400cd5..f095de6 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -245,7 +245,7 @@ static int get_rx_bufs(struct vhost_virtqueue
> *vq,
>  	int r, nlogs = 0;
>  
>  	while (datalen > 0) {
> -		if (unlikely(headcount >= VHOST_NET_MAX_SG)) {
> +		if (unlikely(seg >= VHOST_NET_MAX_SG)) {
>  			r = -ENOBUFS;
>  			goto err;
>  		}
> -- 
> 1.7.3.rc1.5.ge5969
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/virtualization
