From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] virtio_net: fix PAGE_SIZE > 64k
Date: Tue, 24 Jan 2017 04:46:20 +0800
Message-ID: <201701240451.9IOHWr3k%fengguang.wu@intel.com>
References: <1485189896-20327-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1485189896-20327-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael,

[auto build test WARNING on net-next/master]
[also build test WARNING on v4.10-rc5 next-20170123]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Michael-S-Tsirkin/virtio_net-fix-PAGE_SIZE-64k/20170124-023805
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:253:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> drivers/net/virtio_net.c:250:44: sparse: incompatible types in comparison expression (different signedness)
   drivers/net/virtio_net.c:251:33: sparse: incompatible types in comparison expression (different signedness)
   drivers/net/virtio_net.c:256:36: sparse: incompatible types in comparison expression (different signedness)
   drivers/net/virtio_net.c:262:40: sparse: incompatible types in comparison expression (different signedness)
   drivers/net/virtio_net.c:861:16: sparse: incompatible types in comparison expression (different signedness)
   drivers/net/virtio_net.c:861:16: sparse: incompatible types in comparison expression (different signedness)
   In file included from include/linux/list.h:8:0,
                    from include/linux/timer.h:4,
                    from include/linux/netdevice.h:28,
                    from drivers/net/virtio_net.c:19:
   drivers/net/virtio_net.c: In function 'mergeable_ctx_to_buf_truesize':
   include/linux/kernel.h:763:16: warning: comparison of distinct pointer types lacks a cast
     (void) (&max1 == &max2);   \
                   ^
   include/linux/kernel.h:766:2: note: in expansion of macro '__max'
     __max(typeof(x), typeof(y),   \
     ^~~~~
   drivers/net/virtio_net.c:59:32: note: in expansion of macro 'max'
    #define MERGEABLE_BUFFER_ALIGN max(L1_CACHE_BYTES, \
                                   ^~~
   drivers/net/virtio_net.c:250:37: note: in expansion of macro 'MERGEABLE_BUFFER_ALIGN'
     unsigned int truesize = mrg_ctx & (MERGEABLE_BUFFER_ALIGN - 1);
                                        ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:763:16: warning: comparison of distinct pointer types lacks a cast
     (void) (&max1 == &max2);   \
                   ^
   include/linux/kernel.h:766:2: note: in expansion of macro '__max'
     __max(typeof(x), typeof(y),   \
     ^~~~~
   drivers/net/virtio_net.c:59:32: note: in expansion of macro 'max'
    #define MERGEABLE_BUFFER_ALIGN max(L1_CACHE_BYTES, \
                                   ^~~
   drivers/net/virtio_net.c:251:26: note: in expansion of macro 'MERGEABLE_BUFFER_ALIGN'
     return (truesize + 1) * MERGEABLE_BUFFER_ALIGN;
                             ^~~~~~~~~~~~~~~~~~~~~~
   drivers/net/virtio_net.c: In function 'mergeable_ctx_to_buf_address':
   include/linux/kernel.h:763:16: warning: comparison of distinct pointer types lacks a cast
     (void) (&max1 == &max2);   \
                   ^
   include/linux/kernel.h:766:2: note: in expansion of macro '__max'
     __max(typeof(x), typeof(y),   \
     ^~~~~
   drivers/net/virtio_net.c:59:32: note: in expansion of macro 'max'
    #define MERGEABLE_BUFFER_ALIGN max(L1_CACHE_BYTES, \
                                   ^~~
   drivers/net/virtio_net.c:256:29: note: in expansion of macro 'MERGEABLE_BUFFER_ALIGN'
     return (void *)(mrg_ctx & -MERGEABLE_BUFFER_ALIGN);
                                ^~~~~~~~~~~~~~~~~~~~~~
   drivers/net/virtio_net.c: In function 'mergeable_buf_to_ctx':
   include/linux/kernel.h:763:16: warning: comparison of distinct pointer types lacks a cast
     (void) (&max1 == &max2);   \
                   ^
   include/linux/kernel.h:766:2: note: in expansion of macro '__max'
     __max(typeof(x), typeof(y),   \
     ^~~~~
   drivers/net/virtio_net.c:59:32: note: in expansion of macro 'max'
    #define MERGEABLE_BUFFER_ALIGN max(L1_CACHE_BYTES, \
                                   ^~~
   drivers/net/virtio_net.c:262:33: note: in expansion of macro 'MERGEABLE_BUFFER_ALIGN'
     unsigned int size = truesize / MERGEABLE_BUFFER_ALIGN;
                                    ^~~~~~~~~~~~~~~~~~~~~~
   In file included from include/linux/cache.h:4:0,
                    from include/linux/printk.h:8,
                    from include/linux/kernel.h:13,
                    from include/linux/list.h:8,
                    from include/linux/timer.h:4,
                    from include/linux/netdevice.h:28,
                    from drivers/net/virtio_net.c:19:
   drivers/net/virtio_net.c: In function 'get_mergeable_buf_len':
   include/linux/kernel.h:763:16: warning: comparison of distinct pointer types lacks a cast
     (void) (&max1 == &max2);   \
                   ^
   include/uapi/linux/kernel.h:10:47: note: in definition of macro '__ALIGN_KERNEL_MASK'
    #define __ALIGN_KERNEL_MASK(x, mask) (((x) + (mask)) & ~(mask))
                                                  ^~~~
   include/linux/kernel.h:49:22: note: in expansion of macro '__ALIGN_KERNEL'
    #define ALIGN(x, a)  __ALIGN_KERNEL((x), (a))
                         ^~~~~~~~~~~~~~
   drivers/net/virtio_net.c:861:9: note: in expansion of macro 'ALIGN'
     return ALIGN(len, MERGEABLE_BUFFER_ALIGN);
            ^~~~~
   include/linux/kernel.h:766:2: note: in expansion of macro '__max'
     __max(typeof(x), typeof(y),   \
     ^~~~~
   drivers/net/virtio_net.c:59:32: note: in expansion of macro 'max'
    #define MERGEABLE_BUFFER_ALIGN max(L1_CACHE_BYTES, \
                                   ^~~
   drivers/net/virtio_net.c:861:20: note: in expansion of macro 'MERGEABLE_BUFFER_ALIGN'
     return ALIGN(len, MERGEABLE_BUFFER_ALIGN);
                       ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/kernel.h:763:16: warning: comparison of distinct pointer types lacks a cast
     (void) (&max1 == &max2);   \
                   ^
   include/uapi/linux/kernel.h:10:58: note: in definition of macro '__ALIGN_KERNEL_MASK'
    #define __ALIGN_KERNEL_MASK(x, mask) (((x) + (mask)) & ~(mask))
                                                             ^~~~
   include/linux/kernel.h:49:22: note: in expansion of macro '__ALIGN_KERNEL'
    #define ALIGN(x, a)  __ALIGN_KERNEL((x), (a))
                         ^~~~~~~~~~~~~~
   drivers/net/virtio_net.c:861:9: note: in expansion of macro 'ALIGN'
     return ALIGN(len, MERGEABLE_BUFFER_ALIGN);

vim +250 drivers/net/virtio_net.c

fb6813f4 Rusty Russell  2008-07-25  234  	return p;
fb6813f4 Rusty Russell  2008-07-25  235  }
fb6813f4 Rusty Russell  2008-07-25  236  
e9d7417b Jason Wang     2012-12-07  237  static void skb_xmit_done(struct virtqueue *vq)
296f96fc Rusty Russell  2007-10-22  238  {
e9d7417b Jason Wang     2012-12-07  239  	struct virtnet_info *vi = vq->vdev->priv;
296f96fc Rusty Russell  2007-10-22  240  
2cb9c6ba Rusty Russell  2008-02-04  241  	/* Suppress further interrupts. */
e9d7417b Jason Wang     2012-12-07  242  	virtqueue_disable_cb(vq);
11a3a154 Rusty Russell  2008-05-26  243  
363f1514 Rusty Russell  2008-06-08  244  	/* We were probably waiting for more output buffers. */
986a4f4d Jason Wang     2012-12-07  245  	netif_wake_subqueue(vi->dev, vq2txq(vq));
296f96fc Rusty Russell  2007-10-22  246  }
296f96fc Rusty Russell  2007-10-22  247  
ab7db917 Michael Dalton 2014-01-16  248  static unsigned int mergeable_ctx_to_buf_truesize(unsigned long mrg_ctx)
ab7db917 Michael Dalton 2014-01-16  249  {
ab7db917 Michael Dalton 2014-01-16 @250  	unsigned int truesize = mrg_ctx & (MERGEABLE_BUFFER_ALIGN - 1);
ab7db917 Michael Dalton 2014-01-16  251  	return (truesize + 1) * MERGEABLE_BUFFER_ALIGN;
ab7db917 Michael Dalton 2014-01-16  252  }
ab7db917 Michael Dalton 2014-01-16  253  
ab7db917 Michael Dalton 2014-01-16  254  static void *mergeable_ctx_to_buf_address(unsigned long mrg_ctx)
ab7db917 Michael Dalton 2014-01-16  255  {
ab7db917 Michael Dalton 2014-01-16  256  	return (void *)(mrg_ctx & -MERGEABLE_BUFFER_ALIGN);
ab7db917 Michael Dalton 2014-01-16  257  
ab7db917 Michael Dalton 2014-01-16  258  }

:::::: The code at line 250 was first introduced by commit
:::::: ab7db91705e95ed1bba1304388936fccfa58c992 virtio-net: auto-tune mergeable rx buffer size for improved performance

:::::: TO: Michael Dalton <mwdalton@google.com>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
