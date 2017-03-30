From: kbuild test robot <fengguang.wu@intel.com>
Subject: [vhost:linux-next 6/19]
 drivers/remoteproc/remoteproc_virtio.c:106:33: sparse: not enough arguments
 for function vring_new_virtqueue
Date: Thu, 30 Mar 2017 10:08:10 +0800
Message-ID: <201703301006.UmKjTRhG%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:44280 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751941AbdC3CIS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 22:08:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git linux-next
head:   8ab881d0e8136390da79aa0902fe03d2f6c65e32
commit: 281310d52c1d63630f54b1ac5cca6e9eb8715b3a [6/19] virtio: add context flag to find vqs
reproduce:
        # apt-get install sparse
        git checkout 281310d52c1d63630f54b1ac5cca6e9eb8715b3a
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:264:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> drivers/remoteproc/remoteproc_virtio.c:106:33: sparse: not enough arguments for function vring_new_virtqueue
   drivers/remoteproc/remoteproc_virtio.c: In function 'rp_find_vq':
   drivers/remoteproc/remoteproc_virtio.c:107:27: error: passing argument 8 of 'vring_new_virtqueue' from incompatible pointer type [-Werror=incompatible-pointer-types]
         rproc_virtio_notify, callback, name);
                              ^~~~~~~~
   In file included from drivers/remoteproc/remoteproc_virtio.c:25:0:
   include/linux/virtio_ring.h:93:19: note: expected 'bool (*)(struct virtqueue *) {aka _Bool (*)(struct virtqueue *)}' but argument is of type 'void (*)(struct virtqueue *)'
    struct virtqueue *vring_new_virtqueue(unsigned int index,
                      ^~~~~~~~~~~~~~~~~~~
   drivers/remoteproc/remoteproc_virtio.c:107:37: error: passing argument 9 of 'vring_new_virtqueue' from incompatible pointer type [-Werror=incompatible-pointer-types]
         rproc_virtio_notify, callback, name);
                                        ^~~~
   In file included from drivers/remoteproc/remoteproc_virtio.c:25:0:
   include/linux/virtio_ring.h:93:19: note: expected 'void (*)(struct virtqueue *)' but argument is of type 'const char *'
    struct virtqueue *vring_new_virtqueue(unsigned int index,
                      ^~~~~~~~~~~~~~~~~~~
   drivers/remoteproc/remoteproc_virtio.c:106:7: error: too few arguments to function 'vring_new_virtqueue'
     vq = vring_new_virtqueue(id, len, rvring->align, vdev, false, addr,
          ^~~~~~~~~~~~~~~~~~~
   In file included from drivers/remoteproc/remoteproc_virtio.c:25:0:
   include/linux/virtio_ring.h:93:19: note: declared here
    struct virtqueue *vring_new_virtqueue(unsigned int index,
                      ^~~~~~~~~~~~~~~~~~~
   drivers/remoteproc/remoteproc_virtio.c: At top level:
   drivers/remoteproc/remoteproc_virtio.c:264:14: error: initialization from incompatible pointer type [-Werror=incompatible-pointer-types]
     .find_vqs = rproc_virtio_find_vqs,
                 ^~~~~~~~~~~~~~~~~~~~~
   drivers/remoteproc/remoteproc_virtio.c:264:14: note: (near initialization for 'rproc_virtio_config_ops.find_vqs')
   cc1: some warnings being treated as errors

vim +106 drivers/remoteproc/remoteproc_virtio.c

6457f126c drivers/remoteproc/remoteproc_virtio.c Michael S. Tsirkin 2012-09-05   90  
6db20ea8d drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-05-17   91  	rvring = &rvdev->vring[id];
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13   92  	addr = rvring->va;
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13   93  	len = rvring->len;
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20   94  
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13   95  	/* zero vring */
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13   96  	size = vring_size(len, rvring->align);
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13   97  	memset(addr, 0, size);
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20   98  
b5ab5e24e drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-05-30   99  	dev_dbg(dev, "vring%d: va %p qsz %d notifyid %d\n",
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13  100  		id, addr, len, rvring->notifyid);
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  101  
dd6da1c5e drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2012-01-12  102  	/*
dd6da1c5e drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2012-01-12  103  	 * Create the new vq, and tell virtio we're not interested in
dd6da1c5e drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2012-01-12  104  	 * the 'weak' smp barriers, since we're talking with a real device.
dd6da1c5e drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2012-01-12  105  	 */
17bb6d408 drivers/remoteproc/remoteproc_virtio.c Jason Wang         2012-08-28 @106  	vq = vring_new_virtqueue(id, len, rvring->align, vdev, false, addr,
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  107  				 rproc_virtio_notify, callback, name);
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  108  	if (!vq) {
b5ab5e24e drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-05-30  109  		dev_err(dev, "vring_new_virtqueue %s failed\n", name);
6db20ea8d drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-05-17  110  		rproc_free_vring(rvring);
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13  111  		return ERR_PTR(-ENOMEM);
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  112  	}
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  113  
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13  114  	rvring->vq = vq;

:::::: The code at line 106 was first introduced by commit
:::::: 17bb6d40880d4178f5f8a75900ed8c9ff47d3fb2 virtio-ring: move queue_index to vring_virtqueue

:::::: TO: Jason Wang <jasowang@redhat.com>
:::::: CC: Rusty Russell <rusty@rustcorp.com.au>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
