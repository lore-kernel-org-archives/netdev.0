From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] virtio: don't set VIRTIO_NET_HDR_F_DATA_VALID on xmit
Date: Thu, 19 Jan 2017 11:06:59 +0800
Message-ID: <4993cc72-54ab-a74d-cd39-034cff55613f@redhat.com>
References: <20170117181351.98291-1-rolf.neugebauer@docker.com>
 <20170117202515-mutt-send-email-mst@kernel.org>
 <34158479-8d4a-3761-a02e-66c474aca53e@redhat.com>
 <20170118171726-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Rolf Neugebauer <rolf.neugebauer@docker.com>,
        netdev@vger.kernel.org, davem@davemloft.net,
        rppt@linux.vnet.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46920 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751656AbdASDHt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 22:07:49 -0500
In-Reply-To: <20170118171726-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月18日 23:18, Michael S. Tsirkin wrote:
> On Wed, Jan 18, 2017 at 11:54:21AM +0800, Jason Wang wrote:
>> On 2017年01月18日 02:27, Michael S. Tsirkin wrote:
>>> On Tue, Jan 17, 2017 at 06:13:51PM +0000, Rolf Neugebauer wrote:
>>>> This patch part reverts fd2a0437dc33 and e858fae2b0b8 which introduced a
>>>> subtle change in how the virtio_net flags are derived from the SKBs
>>>> ip_summed field.
>>>>
>>>> With the above commits, the flags are set to VIRTIO_NET_HDR_F_DATA_VALID
>>>> when ip_summed == CHECKSUM_UNNECESSARY, thus treating it differently to
>>>> ip_summed == CHECKSUM_NONE, which should be the same.
>>>>
>>>> Further, the virtio spec 1.0 / CS04 explicitly says that
>>>> VIRTIO_NET_HDR_F_DATA_VALID must not be set by the driver.
>>>>
>>>> Signed-off-by: Rolf Neugebauer<rolf.neugebauer@docker.com>
>>> Fixes: fd2a0437dc33 ("virtio_net: introduce virtio_net_hdr_{from,to}_skb")
>>> Fixes: e858fae2b0b8 (" virtio_net: use common code for virtio_net_hdr and skb GSO conversion")
>>> Acked-by: Michael S. Tsirkin<mst@redhat.com>
>>>
>>> Should be backported into stable as well.
>> Looks like a side effect is that we will never see this on receive path?
> I thought receive path is using virtio_net_hdr_to_skb - isn't it?
>

The problem is tun use this on xmit.

Thanks
