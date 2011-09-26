From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] virtio-net: Prevent NULL dereference
Date: Mon, 26 Sep 2011 21:47:03 +0300
Message-ID: <20110926184703.GB22278@redhat.com>
References: <1317058869-19276-1-git-send-email-levinsasha928@gmail.com>
 <1317058869-19276-2-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752375Ab1IZSqT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Sep 2011 14:46:19 -0400
Content-Disposition: inline
In-Reply-To: <1317058869-19276-2-git-send-email-levinsasha928@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2011 at 08:41:09PM +0300, Sasha Levin wrote:
> This patch prevents a NULL dereference when the user has passed a length
> longer than an actual buffer to virtio-net.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: virtualization@lists.linux-foundation.org
> Cc: netdev@vger.kernel.org
> Cc: kvm@vger.kernel.org
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

Hmm, another protection against a buggy device, right?
No problem with that, but let's discard the packet
and print a disgnostic, so that the user can discover
what happened.

> ---
>  drivers/net/virtio_net.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 64e0717..8d32c1e 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -198,7 +198,7 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
>  	len -= copy;
>  	offset += copy;
>  
> -	while (len) {
> +	while (len && page) {
>  		set_skb_frag(skb, page, offset, &len);
>  		page = (struct page *)page->private;
>  		offset = 0;
> -- 
> 1.7.6.1
