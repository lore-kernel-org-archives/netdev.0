From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio: don't set VIRTIO_NET_HDR_F_DATA_VALID on xmit
Date: Tue, 17 Jan 2017 14:08:02 -0500 (EST)
Message-ID: <20170117.140802.2168924400117428792.davem@davemloft.net>
References: <20170117181351.98291-1-rolf.neugebauer@docker.com>
        <20170117202515-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rolf.neugebauer@docker.com, netdev@vger.kernel.org,
        jasowang@redhat.com, rppt@linux.vnet.ibm.com
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41442 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751132AbdAQTID (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:08:03 -0500
In-Reply-To: <20170117202515-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 17 Jan 2017 20:27:33 +0200

> On Tue, Jan 17, 2017 at 06:13:51PM +0000, Rolf Neugebauer wrote:
>> This patch part reverts fd2a0437dc33 and e858fae2b0b8 which introduced a
>> subtle change in how the virtio_net flags are derived from the SKBs
>> ip_summed field.
>> 
>> With the above commits, the flags are set to VIRTIO_NET_HDR_F_DATA_VALID
>> when ip_summed == CHECKSUM_UNNECESSARY, thus treating it differently to
>> ip_summed == CHECKSUM_NONE, which should be the same.
>> 
>> Further, the virtio spec 1.0 / CS04 explicitly says that
>> VIRTIO_NET_HDR_F_DATA_VALID must not be set by the driver.
>> 
>> Signed-off-by: Rolf Neugebauer <rolf.neugebauer@docker.com>
> 
> Fixes: fd2a0437dc33 ("virtio_net: introduce virtio_net_hdr_{from,to}_skb")
> Fixes: e858fae2b0b8 (" virtio_net: use common code for virtio_net_hdr and skb GSO conversion")
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Should be backported into stable as well.

Applied and queued up for -stable, thanks everyone.
