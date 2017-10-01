From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] vhost_net: do not stall on zerocopy depletion
Date: Sun, 1 Oct 2017 06:20:49 +0300
Message-ID: <20171001062018-mutt-send-email-mst@kernel.org>
References: <20170928002556.41240-1-willemdebruijn.kernel@gmail.com>
 <201710010753.KeY9a5xF%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
        jasowang@redhat.com, den@klaipeden.com,
        virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46804 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750730AbdJADUv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 30 Sep 2017 23:20:51 -0400
Content-Disposition: inline
In-Reply-To: <201710010753.KeY9a5xF%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 01, 2017 at 08:09:30AM +0800, kbuild test robot wrote:
> Hi Willem,
> 
> [auto build test WARNING on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Willem-de-Bruijn/vhost_net-do-not-stall-on-zerocopy-depletion/20171001-054709
> reproduce:
>         # apt-get install sparse
>         make ARCH=x86_64 allmodconfig
>         make C=1 CF=-D__CHECK_ENDIAN__

BTW __CHECK_ENDIAN__ is the default now, I think you can drop it from
your scripts.

> 
> sparse warnings: (new ones prefixed by >>)
> 
> 
> vim +440 drivers/vhost/net.c
> 
>    433	
>    434	static bool vhost_exceeds_maxpend(struct vhost_net *net)
>    435	{
>    436		struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
>    437		struct vhost_virtqueue *vq = &nvq->vq;
>    438	
>    439		return (nvq->upend_idx + UIO_MAXIOV - nvq->done_idx) % UIO_MAXIOV >
>  > 440		       min(VHOST_MAX_PEND, vq->num >> 2);
>    441	}
>    442	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
