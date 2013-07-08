From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 0/2] virtio_net: fix race in RX VQ processing
Date: Mon, 8 Jul 2013 12:05:26 +0300
Message-ID: <1373274069-4301-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Wang reported a race in RX VQ processing:
virtqueue_enable_cb is called outside napi lock,
violating virtio serialization rules.
The race has been there from day 1, but it got especially nasty in 3.0
when commit a5c262c5fd83ece01bd649fb08416c501d4c59d7
"virtio_ring: support event idx feature"
added more dependency on vq state.

Please review, and consider for 3.11 and for stable.

Jason, could you please report whether this fixes the issues for you?
