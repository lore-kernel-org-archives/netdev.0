From: kbuild test robot <fengguang.wu@intel.com>
Subject: [vhost:linux-next 6/19]
 drivers//remoteproc/remoteproc_virtio.c:106:7: error: too few arguments to
 function 'vring_new_virtqueue'
Date: Thu, 30 Mar 2017 06:53:51 +0800
Message-ID: <201703300647.A5Noh5I7%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3MwIy2ne0vdjdPXF"
Content-Transfer-Encoding: 8bit
Cc: kbuild-all@01.org, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2967 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752656AbdC2Wyr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 18:54:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git linux-next
head:   8ab881d0e8136390da79aa0902fe03d2f6c65e32
commit: 281310d52c1d63630f54b1ac5cca6e9eb8715b3a [6/19] virtio: add context flag to find vqs
config: x86_64-randconfig-i0-201713 (attached as .config)
compiler: gcc-4.9 (Debian 4.9.4-2) 4.9.4
reproduce:
        git checkout 281310d52c1d63630f54b1ac5cca6e9eb8715b3a
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All error/warnings (new ones prefixed by >>):

   drivers//remoteproc/remoteproc_virtio.c: In function 'rp_find_vq':
>> drivers//remoteproc/remoteproc_virtio.c:107:27: warning: passing argument 8 of 'vring_new_virtqueue' from incompatible pointer type
         rproc_virtio_notify, callback, name);
                              ^
   In file included from drivers//remoteproc/remoteproc_virtio.c:25:0:
   include/linux/virtio_ring.h:93:19: note: expected 'bool (*)(struct virtqueue *)' but argument is of type 'void (*)(struct virtqueue *)'
    struct virtqueue *vring_new_virtqueue(unsigned int index,
                      ^
   drivers//remoteproc/remoteproc_virtio.c:107:37: warning: passing argument 9 of 'vring_new_virtqueue' from incompatible pointer type
         rproc_virtio_notify, callback, name);
                                        ^
   In file included from drivers//remoteproc/remoteproc_virtio.c:25:0:
   include/linux/virtio_ring.h:93:19: note: expected 'void (*)(struct virtqueue *)' but argument is of type 'const char *'
    struct virtqueue *vring_new_virtqueue(unsigned int index,
                      ^
>> drivers//remoteproc/remoteproc_virtio.c:106:7: error: too few arguments to function 'vring_new_virtqueue'
     vq = vring_new_virtqueue(id, len, rvring->align, vdev, false, addr,
          ^
   In file included from drivers//remoteproc/remoteproc_virtio.c:25:0:
   include/linux/virtio_ring.h:93:19: note: declared here
    struct virtqueue *vring_new_virtqueue(unsigned int index,
                      ^
   drivers//remoteproc/remoteproc_virtio.c: At top level:
>> drivers//remoteproc/remoteproc_virtio.c:264:2: warning: initialization from incompatible pointer type
     .find_vqs = rproc_virtio_find_vqs,
     ^
   drivers//remoteproc/remoteproc_virtio.c:264:2: warning: (near initialization for 'rproc_virtio_config_ops.find_vqs')

vim +/vring_new_virtqueue +106 drivers//remoteproc/remoteproc_virtio.c

7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13  100  		id, addr, len, rvring->notifyid);
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  101  
dd6da1c5e drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2012-01-12  102  	/*
dd6da1c5e drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2012-01-12  103  	 * Create the new vq, and tell virtio we're not interested in
dd6da1c5e drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2012-01-12  104  	 * the 'weak' smp barriers, since we're talking with a real device.
dd6da1c5e drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2012-01-12  105  	 */
17bb6d408 drivers/remoteproc/remoteproc_virtio.c Jason Wang         2012-08-28 @106  	vq = vring_new_virtqueue(id, len, rvring->align, vdev, false, addr,
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20 @107  				 rproc_virtio_notify, callback, name);
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  108  	if (!vq) {
b5ab5e24e drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-05-30  109  		dev_err(dev, "vring_new_virtqueue %s failed\n", name);
6db20ea8d drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-05-17  110  		rproc_free_vring(rvring);
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13  111  		return ERR_PTR(-ENOMEM);
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  112  	}
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  113  
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13  114  	rvring->vq = vq;
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13  115  	vq->priv = rvring;
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  116  
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  117  	return vq;
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  118  }
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  119  
dab55bbaf drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-11-12  120  static void __rproc_virtio_del_vqs(struct virtio_device *vdev)
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  121  {
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  122  	struct virtqueue *vq, *n;
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13  123  	struct rproc_vring *rvring;
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  124  
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  125  	list_for_each_entry_safe(vq, n, &vdev->vqs, list) {
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13  126  		rvring = vq->priv;
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13  127  		rvring->vq = NULL;
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  128  		vring_del_virtqueue(vq);
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  129  	}
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  130  }
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  131  
dab55bbaf drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-11-12  132  static void rproc_virtio_del_vqs(struct virtio_device *vdev)
dab55bbaf drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-11-12  133  {
dab55bbaf drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-11-12  134  	__rproc_virtio_del_vqs(vdev);
dab55bbaf drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-11-12  135  }
dab55bbaf drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-11-12  136  
f145928d4 drivers/remoteproc/remoteproc_virtio.c Anna, Suman        2016-08-12  137  static int rproc_virtio_find_vqs(struct virtio_device *vdev, unsigned int nvqs,
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  138  				 struct virtqueue *vqs[],
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  139  				 vq_callback_t *callbacks[],
fb5e31d97 drivers/remoteproc/remoteproc_virtio.c Christoph Hellwig  2017-02-05  140  				 const char * const names[],
fb5e31d97 drivers/remoteproc/remoteproc_virtio.c Christoph Hellwig  2017-02-05  141  				 struct irq_affinity *desc)
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  142  {
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  143  	int i, ret;
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  144  
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  145  	for (i = 0; i < nvqs; ++i) {
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  146  		vqs[i] = rp_find_vq(vdev, i, callbacks[i], names[i]);
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  147  		if (IS_ERR(vqs[i])) {
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  148  			ret = PTR_ERR(vqs[i]);
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  149  			goto error;
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  150  		}
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  151  	}
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  152  
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  153  	return 0;
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  154  
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  155  error:
dab55bbaf drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-11-12  156  	__rproc_virtio_del_vqs(vdev);
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  157  	return ret;
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  158  }
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  159  
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  160  static u8 rproc_virtio_get_status(struct virtio_device *vdev)
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  161  {
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  162  	struct rproc_vdev *rvdev = vdev_to_rvdev(vdev);
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  163  	struct fw_rsc_vdev *rsc;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  164  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  165  	rsc = (void *)rvdev->rproc->table_ptr + rvdev->rsc_offset;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  166  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  167  	return rsc->status;
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  168  }
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  169  
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  170  static void rproc_virtio_set_status(struct virtio_device *vdev, u8 status)
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  171  {
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  172  	struct rproc_vdev *rvdev = vdev_to_rvdev(vdev);
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  173  	struct fw_rsc_vdev *rsc;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  174  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  175  	rsc = (void *)rvdev->rproc->table_ptr + rvdev->rsc_offset;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  176  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  177  	rsc->status = status;
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13  178  	dev_dbg(&vdev->dev, "status: %d\n", status);
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  179  }
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  180  
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  181  static void rproc_virtio_reset(struct virtio_device *vdev)
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  182  {
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  183  	struct rproc_vdev *rvdev = vdev_to_rvdev(vdev);
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  184  	struct fw_rsc_vdev *rsc;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  185  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  186  	rsc = (void *)rvdev->rproc->table_ptr + rvdev->rsc_offset;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  187  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  188  	rsc->status = 0;
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  189  	dev_dbg(&vdev->dev, "reset !\n");
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  190  }
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  191  
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  192  /* provide the vdev features as retrieved from the firmware */
d02547736 drivers/remoteproc/remoteproc_virtio.c Michael S. Tsirkin 2014-10-07  193  static u64 rproc_virtio_get_features(struct virtio_device *vdev)
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  194  {
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13  195  	struct rproc_vdev *rvdev = vdev_to_rvdev(vdev);
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  196  	struct fw_rsc_vdev *rsc;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  197  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  198  	rsc = (void *)rvdev->rproc->table_ptr + rvdev->rsc_offset;
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  199  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  200  	return rsc->dfeatures;
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  201  }
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  202  
5c609a5ef drivers/remoteproc/remoteproc_virtio.c Michael S. Tsirkin 2014-12-04  203  static int rproc_virtio_finalize_features(struct virtio_device *vdev)
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  204  {
7a1869416 drivers/remoteproc/remoteproc_virtio.c Ohad Ben-Cohen     2012-02-13  205  	struct rproc_vdev *rvdev = vdev_to_rvdev(vdev);
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  206  	struct fw_rsc_vdev *rsc;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  207  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  208  	rsc = (void *)rvdev->rproc->table_ptr + rvdev->rsc_offset;
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  209  
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  210  	/* Give virtio_ring a chance to accept features */
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  211  	vring_transport_features(vdev);
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  212  
93d389f82 drivers/remoteproc/remoteproc_virtio.c Michael S. Tsirkin 2014-11-27  213  	/* Make sure we don't have any features > 32 bits! */
93d389f82 drivers/remoteproc/remoteproc_virtio.c Michael S. Tsirkin 2014-11-27  214  	BUG_ON((u32)vdev->features != vdev->features);
93d389f82 drivers/remoteproc/remoteproc_virtio.c Michael S. Tsirkin 2014-11-27  215  
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  216  	/*
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  217  	 * Remember the finalized features of our vdev, and provide it
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  218  	 * to the remote processor once it is powered on.
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  219  	 */
e16e12be3 drivers/remoteproc/remoteproc_virtio.c Michael S. Tsirkin 2014-10-07  220  	rsc->gfeatures = vdev->features;
5c609a5ef drivers/remoteproc/remoteproc_virtio.c Michael S. Tsirkin 2014-12-04  221  
5c609a5ef drivers/remoteproc/remoteproc_virtio.c Michael S. Tsirkin 2014-12-04  222  	return 0;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  223  }
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  224  
f145928d4 drivers/remoteproc/remoteproc_virtio.c Anna, Suman        2016-08-12  225  static void rproc_virtio_get(struct virtio_device *vdev, unsigned int offset,
f145928d4 drivers/remoteproc/remoteproc_virtio.c Anna, Suman        2016-08-12  226  			     void *buf, unsigned int len)
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  227  {
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  228  	struct rproc_vdev *rvdev = vdev_to_rvdev(vdev);
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  229  	struct fw_rsc_vdev *rsc;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  230  	void *cfg;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  231  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  232  	rsc = (void *)rvdev->rproc->table_ptr + rvdev->rsc_offset;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  233  	cfg = &rsc->vring[rsc->num_of_vrings];
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  234  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  235  	if (offset + len > rsc->config_len || offset + len < len) {
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  236  		dev_err(&vdev->dev, "rproc_virtio_get: access out of bounds\n");
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  237  		return;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  238  	}
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  239  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  240  	memcpy(buf, cfg + offset, len);
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  241  }
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  242  
f145928d4 drivers/remoteproc/remoteproc_virtio.c Anna, Suman        2016-08-12  243  static void rproc_virtio_set(struct virtio_device *vdev, unsigned int offset,
f145928d4 drivers/remoteproc/remoteproc_virtio.c Anna, Suman        2016-08-12  244  			     const void *buf, unsigned int len)
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  245  {
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  246  	struct rproc_vdev *rvdev = vdev_to_rvdev(vdev);
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  247  	struct fw_rsc_vdev *rsc;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  248  	void *cfg;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  249  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  250  	rsc = (void *)rvdev->rproc->table_ptr + rvdev->rsc_offset;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  251  	cfg = &rsc->vring[rsc->num_of_vrings];
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  252  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  253  	if (offset + len > rsc->config_len || offset + len < len) {
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  254  		dev_err(&vdev->dev, "rproc_virtio_set: access out of bounds\n");
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  255  		return;
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  256  	}
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  257  
92b38f851 drivers/remoteproc/remoteproc_virtio.c Sjur Brændeland    2013-02-21  258  	memcpy(cfg + offset, buf, len);
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  259  }
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  260  
935039323 drivers/remoteproc/remoteproc_virtio.c Stephen Hemminger  2013-02-10  261  static const struct virtio_config_ops rproc_virtio_config_ops = {
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  262  	.get_features	= rproc_virtio_get_features,
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  263  	.finalize_features = rproc_virtio_finalize_features,
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20 @264  	.find_vqs	= rproc_virtio_find_vqs,
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  265  	.del_vqs	= rproc_virtio_del_vqs,
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  266  	.reset		= rproc_virtio_reset,
ac8954a41 drivers/remoteproc/remoteproc_rpmsg.c  Ohad Ben-Cohen     2011-10-20  267  	.set_status	= rproc_virtio_set_status,

:::::: The code at line 106 was first introduced by commit
:::::: 17bb6d40880d4178f5f8a75900ed8c9ff47d3fb2 virtio-ring: move queue_index to vring_virtqueue

:::::: TO: Jason Wang <jasowang@redhat.com>
:::::: CC: Rusty Russell <rusty@rustcorp.com.au>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--3MwIy2ne0vdjdPXF
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
oE4oOFgf8EB+RrYmFEYD/gcVn3QOO58BAA==

--3MwIy2ne0vdjdPXF--
