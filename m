From: kbuild test robot <fengguang.wu@intel.com>
Subject: [vhost:linux-next 6/19]
 drivers/remoteproc/remoteproc_virtio.c:107:27: error: passing argument 8 of
 'vring_new_virtqueue' from incompatible pointer type
Date: Thu, 30 Mar 2017 06:40:03 +0800
Message-ID: <201703300600.3QLtFqiW%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Content-Transfer-Encoding: 8bit
Cc: kbuild-all@01.org, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:57179 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932607AbdC2Wkp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 18:40:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git linux-next
head:   8ab881d0e8136390da79aa0902fe03d2f6c65e32
commit: 281310d52c1d63630f54b1ac5cca6e9eb8715b3a [6/19] virtio: add context flag to find vqs
config: i386-randconfig-s0-201713 (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        git checkout 281310d52c1d63630f54b1ac5cca6e9eb8715b3a
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   drivers/remoteproc/remoteproc_virtio.c: In function 'rp_find_vq':
>> drivers/remoteproc/remoteproc_virtio.c:107:27: error: passing argument 8 of 'vring_new_virtqueue' from incompatible pointer type [-Werror=incompatible-pointer-types]
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
>> drivers/remoteproc/remoteproc_virtio.c:264:14: error: initialization from incompatible pointer type [-Werror=incompatible-pointer-types]
     .find_vqs = rproc_virtio_find_vqs,
                 ^~~~~~~~~~~~~~~~~~~~~
   drivers/remoteproc/remoteproc_virtio.c:264:14: note: (near initialization for 'rproc_virtio_config_ops.find_vqs')
   cc1: some warnings being treated as errors

vim +/vring_new_virtqueue +107 drivers/remoteproc/remoteproc_virtio.c

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

:::::: The code at line 107 was first introduced by commit
:::::: ac8954a413930dae3c53f7e782f09a94e7eae88b remoteproc: create rpmsg virtio device

:::::: TO: Ohad Ben-Cohen <ohad@wizery.com>
:::::: CC: Ohad Ben-Cohen <ohad@wizery.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--x+6KMIRAuhnl3hBn
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--x+6KMIRAuhnl3hBn--
