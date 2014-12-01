From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC v3 0/3] virtio_net: enabling tx interrupts
Date: Mon, 01 Dec 2014 18:14:36 +0800
Message-ID: <547C3F8C.8000006@redhat.com>
References: <1413787824-16130-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413787824-16130-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 10/20/2014 02:52 PM, Michael S. Tsirkin wrote:
> RFC patches to enable tx interrupts.
> This is to demonstrate how this can be done without
> core virtio changes, and to make sure I understand
> the new APIs correctly.
>
> Testing TBD, I was asked for a version for early testing.
>
> Applies on top of patch: "virtio_net: fix use after free"
> that I recently sent.
>
> Changes from v3:
> 	clean up code, address issues raised by Jason
> Changes from v1:
>          address comments by Jason Wang, use delayed cb everywhere
>          rebased Jason's patch on top of mine and include it (with some tweaks)
>
> Jason Wang (1):
>    virtio-net: optimize free_old_xmit_skbs stats
>
> Michael S. Tsirkin (2):
>    virtio_net: enable tx interrupt
>    virtio_net: bql
>
>   drivers/net/virtio_net.c | 144 +++++++++++++++++++++++++++++++++--------------
>   1 file changed, 101 insertions(+), 43 deletions(-)
>

I've run a full tests on this series and see huge regression when 
zerocopy is disabled. Looks like the reason is zerocopy could coalescing 
tx completion which greatly reduce the number of tx interrupts.

I will post RFC V4 shortly with interrupt coalescing support. In this 
version I remove the tx packet cleanup in ndo_start_xmit() since it may 
reduce the effects of interrupt coalescing.
