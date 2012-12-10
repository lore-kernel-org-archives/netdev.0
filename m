From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 204/207] drivers/net/virtio_net.c:1312
 virtnet_alloc_queues() error: potential null dereference 'vi->rq'.
  (kzalloc returns null)
Date: Mon, 10 Dec 2012 19:14:51 +0800
Message-ID: <50c5c42b.cwK8ksV8A98071UI%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55786 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751284Ab2LJLQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 06:16:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   65d2897c0f1b240420d657f41e561239fa10ba94
commit: 986a4f4d452dec004697f667439d27c3fda9c928 [204/207] virtio_net: multiqueue support


smatch warnings:

+ drivers/net/virtio_net.c:1312 virtnet_alloc_queues() error: potential null dereference 'vi->rq'.  (kzalloc returns null)

vim +1312 drivers/net/virtio_net.c

986a4f4d Jason Wang 2012-12-07  1296  	return ret;
986a4f4d Jason Wang 2012-12-07  1297  }
986a4f4d Jason Wang 2012-12-07  1298  
986a4f4d Jason Wang 2012-12-07  1299  static int virtnet_alloc_queues(struct virtnet_info *vi)
986a4f4d Jason Wang 2012-12-07  1300  {
986a4f4d Jason Wang 2012-12-07  1301  	int i;
986a4f4d Jason Wang 2012-12-07  1302  
986a4f4d Jason Wang 2012-12-07  1303  	vi->sq = kzalloc(sizeof(*vi->sq) * vi->max_queue_pairs, GFP_KERNEL);
986a4f4d Jason Wang 2012-12-07  1304  	if (!vi->sq)
986a4f4d Jason Wang 2012-12-07  1305  		goto err_sq;
986a4f4d Jason Wang 2012-12-07  1306  	vi->rq = kzalloc(sizeof(*vi->rq) * vi->max_queue_pairs, GFP_KERNEL);
986a4f4d Jason Wang 2012-12-07  1307  	if (!vi->sq)
986a4f4d Jason Wang 2012-12-07  1308  		goto err_rq;
986a4f4d Jason Wang 2012-12-07  1309  
986a4f4d Jason Wang 2012-12-07  1310  	INIT_DELAYED_WORK(&vi->refill, refill_work);
986a4f4d Jason Wang 2012-12-07  1311  	for (i = 0; i < vi->max_queue_pairs; i++) {
986a4f4d Jason Wang 2012-12-07 @1312  		vi->rq[i].pages = NULL;
986a4f4d Jason Wang 2012-12-07  1313  		netif_napi_add(vi->dev, &vi->rq[i].napi, virtnet_poll,
986a4f4d Jason Wang 2012-12-07  1314  			       napi_weight);
986a4f4d Jason Wang 2012-12-07  1315  
986a4f4d Jason Wang 2012-12-07  1316  		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
986a4f4d Jason Wang 2012-12-07  1317  		sg_init_table(vi->sq[i].sg, ARRAY_SIZE(vi->sq[i].sg));
986a4f4d Jason Wang 2012-12-07  1318  	}
986a4f4d Jason Wang 2012-12-07  1319  
986a4f4d Jason Wang 2012-12-07  1320  	return 0;

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
