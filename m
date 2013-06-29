From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 2/5] VSOCK: Introduce virtio-vsock-common.ko
Date: Fri, 28 Jun 2013 21:32:25 -0700 (PDT)
Message-ID: <20130628.213225.150653146873611065.davem@davemloft.net>
References: <1372320004-20502-1-git-send-email-asias@redhat.com>
	<1372320004-20502-3-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, acking@vmware.com,
	dtor@vmware.com, grantr@vmware.com, rusty@rustcorp.com.au,
	mst@redhat.com, jasowang@redhat.com, stefanha@gmail.com,
	kraxel@redhat.com, penberg@kernel.org, sasha.levin@oracle.com
To: asias@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab3F2Ec0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 00:32:26 -0400
In-Reply-To: <1372320004-20502-3-git-send-email-asias@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Asias He <asias@redhat.com>
Date: Thu, 27 Jun 2013 16:00:01 +0800

> +static void
> +virtio_transport_recv_dgram(struct sock *sk,
> +			    struct virtio_vsock_pkt *pkt)
 ...
> +	memcpy(skb->data, pkt, sizeof(*pkt));
> +	memcpy(skb->data + sizeof(*pkt), pkt->buf, pkt->len);

Are you sure this is right?

Shouldn't you be using "sizeof(struct virtio_vsock_hdr)" instead of
"sizeof(*pkt)".  'pkt' is "struct virtio_vsock_pkt" and has all kinds
of meta-data you probably don't mean to include in the SKB.
