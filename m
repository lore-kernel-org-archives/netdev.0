From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next] vhost_net: do not stall on zerocopy depletion
Date: Sun, 1 Oct 2017 08:09:30 +0800
Message-ID: <201710010753.KeY9a5xF%fengguang.wu@intel.com>
References: <20170928002556.41240-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
        mst@redhat.com, jasowang@redhat.com, den@klaipeden.com,
        virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:17331 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751243AbdJAAJn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 30 Sep 2017 20:09:43 -0400
Content-Disposition: inline
In-Reply-To: <20170928002556.41240-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Willem,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Willem-de-Bruijn/vhost_net-do-not-stall-on-zerocopy-depletion/20171001-054709
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)


vim +440 drivers/vhost/net.c

   433	
   434	static bool vhost_exceeds_maxpend(struct vhost_net *net)
   435	{
   436		struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
   437		struct vhost_virtqueue *vq = &nvq->vq;
   438	
   439		return (nvq->upend_idx + UIO_MAXIOV - nvq->done_idx) % UIO_MAXIOV >
 > 440		       min(VHOST_MAX_PEND, vq->num >> 2);
   441	}
   442	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
