From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 0/2] virtio_net: fix race in RX VQ processing
Date: Tue, 09 Jul 2013 11:17:05 +0800
Message-ID: <51DB80B1.60009@redhat.com>
References: <1373274069-4301-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19150 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751564Ab3GIDRV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jul 2013 23:17:21 -0400
In-Reply-To: <1373274069-4301-1-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2013 05:05 PM, Michael S. Tsirkin wrote:
> Jason Wang reported a race in RX VQ processing:
> virtqueue_enable_cb is called outside napi lock,
> violating virtio serialization rules.
> The race has been there from day 1, but it got especially nasty in 3.0
> when commit a5c262c5fd83ece01bd649fb08416c501d4c59d7
> "virtio_ring: support event idx feature"
> added more dependency on vq state.
>
> Please review, and consider for 3.11 and for stable.
>
> Jason, could you please report whether this fixes the issues for you?

Yes, I confirm this fixes the issue.

Since I can only reproduce it by adding udelay in virtqueue_enable_cb()
after virtio_mb(). I validate this also with this.

Thanks
