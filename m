From: Qinchuanyu <qinchuanyu@huawei.com>
Subject: provide vhost thread per virtqueue for forwarding scenario
Date: Mon, 20 May 2013 02:11:19 +0000
Message-ID: <5872DA217C2FF7488B20897D84F904E7338FC974@nkgeml511-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: " (netdev@vger.kernel.org)" <netdev@vger.kernel.org>,
	" (kvm@vger.kernel.org)" <kvm@vger.kernel.org>,
	Zanghongyong <zanghongyong@huawei.com>,
	"Zhangjie (HZ)" <zhang.zhangjie@huawei.com>
To: "mst@redhat.com" <mst@redhat.com>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"nab@linux-iscsi.org" <nab@linux-iscsi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:7344 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755107Ab3ETCL6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 22:11:58 -0400
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vhost thread provide both tx and rx ability for virtio-net. 
In the forwarding scenarios, tx and rx share the vhost thread, and throughput is limited by single thread.

So I did a patch for provide vhost thread per virtqueue, not per vhost_net.

Of course, multi-queue virtio-net is final solution, but it require new version of virtio-net working in guest.
If you have to work with suse10,11, redhat 5.x as guest, and want to improve the forward throughput,
using vhost thread per queue seems to be the only solution.

I did the test with kernel 3.0.27 and qemu-1.4.0, guest is suse11-sp2, and then two vhost thread provide 
double tx/rx forwarding performance than signal vhost thread. 
The virtqueue of vhost_blk is 1, so it still use one vhost thread without change.

Is there something wrong in this solution? If not, I would list patch later.

Best regards
King
