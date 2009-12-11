From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH v2 0/4] Defer skb allocation for both mergeable buffers and
 big packets in virtio_net
Date: Fri, 11 Dec 2009 04:28:26 -0800
Message-ID: <1260534506.30371.6.camel@localhost.localdomain>
References: <1258697359.7416.14.camel@localhost.localdomain>
	 <200911231123.18898.rusty@rustcorp.com.au>
	 <20091208122134.GA17286@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:38374 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952AbZLKM2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Dec 2009 07:28:23 -0500
In-Reply-To: <20091208122134.GA17286@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a patch-set for deferring skb allocation based on Rusty and
Michael's inputs.

Guest virtio_net receives packets from its pre-allocated vring 
buffers, then it delivers these packets to upper layer protocols
as skb buffs. So it's not necessary to pre-allocate skb for each
mergable buffer, then frees it when it's useless. 

This patch has deferred skb allocation when receiving packets for
both big packets and mergeable buffers. It reduces skb pre-allocations 
and skb_frees.

A destroy function has been created to push virtio free buffs to vring
for unused pages, and used page private to maintain page list.

This patch has tested and measured against 2.6.32-rc7 git. It is built
again 2.6.32 kernel. Tests have been done for small packets, big packets
and mergeable buffers.

The single netperf TCP_STREAM performance improved for host to guest. 
It also reduces UDP packets drop rate.

Thanks
Shirley

