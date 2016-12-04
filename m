From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v4 1/6] net: virtio dynamically disable/enable
 LRO
Date: Sat, 03 Dec 2016 23:01:03 -0500 (EST)
Message-ID: <20161203.230103.2147950370567010856.davem@davemloft.net>
References: <20161202204804.4331.61904.stgit@john-Precision-Tower-5810>
        <20161202204945.4331.2419.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, mst@redhat.com, shm@cumulusnetworks.com,
        tgraf@suug.ch, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, brouer@redhat.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41880 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752058AbcLDEBY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 23:01:24 -0500
In-Reply-To: <20161202204945.4331.2419.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 02 Dec 2016 12:49:45 -0800

> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_GUEST_OFFLOADS)) {
> +		sg_init_one(&sg, &offloads, sizeof(uint64_t));
> +		if (!virtnet_send_command(vi,
> +					  VIRTIO_NET_CTRL_GUEST_OFFLOADS,
> +					  VIRTIO_NET_CTRL_GUEST_OFFLOADS_SET,
> +					  &sg)) {
> +			dev_warn(&netdev->dev,
> +				 "Failed to set guest offloads by virtnet command.\n");
> +			return -EINVAL;
> +		}
> +	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_GUEST_OFFLOADS) &&
> +		   !virtio_has_feature(vdev, VIRTIO_F_VERSION_1)) {

Hmmm, to me this reads as:

	if (X) {
	 ...
	else if (X && ...) {

I don't see how the second basic block can ever execute.  If the virtio
has the VIRTIO_NET_F_CTRL_GUEST_OFFLOADS feature, we will execute only
the first basic block.

Maybe I misunderstand the logic for whatever reason.
