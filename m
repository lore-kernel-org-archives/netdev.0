From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v3 2/4] virtio_net: Add a set_rx_mode interface
Date: Mon, 2 Feb 2009 20:22:20 +1030
Message-ID: <200902022022.20781.rusty@rustcorp.com.au>
References: <20090201200504.8183.58421.stgit@debian.lart> <20090201200515.8183.81496.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:47903 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106AbZBBJwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2009 04:52:24 -0500
In-Reply-To: <20090201200515.8183.81496.stgit@debian.lart>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 02 February 2009 06:35:15 Alex Williamson wrote:
> +	sg_set_buf(&sg, &promisc, sizeof(promisc));
> +
> +	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
> +				  VIRTIO_NET_CTRL_RX_PROMISC,
> +				  &sg, 1, 0))

Hmm, can we use sg_init_one(&sg, &promisc, sizeof(promisc)) then pass two sg
to virtnet_send_command?  ie.  change virtnet_send_command to:

	static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
                                struct scatterlist *out, struct scatterlist *in);

NULL = no sg, otherwise it's assumed to be a nicely terminated sg?  Neater for
the callers I think...

> -#define VIRTIO_NET_MAX_CTRL_ARGS   2
> +#define VIRTIO_NET_MAX_CTRL_ARGS   3

Oh, and this should probably be called VIRTNET_SEND_COMMAND_SG_MAX, and be
this value minus 2 (ie. informative for the caller of virtnet_send_command).

Thanks,
Rusty.
PS.  Oh, this actual patch was fine: Acked-by: Rusty Russell <rusty@rustcorp.com.au>
