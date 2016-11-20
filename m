From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: add loopback to virtio_transport
Date: Sat, 19 Nov 2016 22:08:04 -0500 (EST)
Message-ID: <20161119.220804.755313313976863187.davem@davemloft.net>
References: <1479397763-22319-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cavery@redhat.com,
        imbrenda@linux.vnet.ibm.com, jhansen@vmware.com
To: stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45830 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752905AbcKTDIN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 22:08:13 -0500
In-Reply-To: <1479397763-22319-1-git-send-email-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Thu, 17 Nov 2016 15:49:23 +0000

> @@ -159,6 +199,10 @@ virtio_transport_send_pkt(struct virtio_vsock_pkt *pkt)
>  		return -ENODEV;
>  	}
>  
> +	if (le32_to_cpu(pkt->hdr.dst_cid) == vsock->guest_cid) {
> +		return virtio_transport_send_pkt_loopback(vsock, pkt);
> +	}
> +

A single-statement basic block should get surrounding curly
braces.
