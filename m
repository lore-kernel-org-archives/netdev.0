From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Sun, 23 Oct 2016 09:38:08 -0700
Message-ID: <20161023093808.161535f3@xeon-e3>
References: <1477109243-29520-1-git-send-email-shrijeet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, tom@herbertland.com, netdev@vger.kernel.org,
        shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com
To: Shrijeet Mukherjee <shrijeet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35946 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754861AbcJWQhz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 12:37:55 -0400
Received: by mail-pf0-f177.google.com with SMTP id e6so84051560pfk.3
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2016 09:37:55 -0700 (PDT)
In-Reply-To: <1477109243-29520-1-git-send-email-shrijeet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Overall, I am glad to see XDP support more widely available. Minor stuff
in implementation.

>  
> +/* this function is not called from the receive_buf path directly as
> + * we want to use the page model for rx merge buffer and big buffers
> + * and not use the fast path for driving skb's around
> + */
> +static inline u32 do_xdp_prog(struct virtnet_info *vi,
> +			      struct receive_queue *rq,
> +			      void *buf, int offset, int len)
> +{

Do not mark non-trivial static functions as inline. The compiler will
do it anyway if it thinks it is appropriate.

+static int virtnet_xdp_query(struct net_device *dev)

Use bool here.

@@ -366,13 +420,22 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
...

 	if (unlikely(!curr_skb))
 		goto err_skb;
+
 	while (--num_buf) {
 		int num_skb_frags;

@@ -1878,7 +2000,6 @@ static int virtnet_probe(struct virtio_device *vdev)
 		if (virtnet_change_mtu(dev, mtu))
 			__virtio_clear_bit(vdev, VIRTIO_NET_F_MTU);
 	}
-
 	if (vi->any_header_sg)
 		dev->needed_headroom = vi->hdr_len;

This parts of the patch is white space creep. I.e other edits you did
that stayed around.

Do you have any performance numbers? Does the receive into pages hurt
the non XDP performance?
