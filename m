From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2 0/2] virtio_net: fix race in RX VQ processing
Date: Tue, 9 Jul 2013 08:12:57 +0300
Message-ID: <1373346713-442-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53995 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751185Ab3GIFLs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jul 2013 01:11:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason Wang reported a race in RX VQ processing:
virtqueue_enable_cb is called outside napi lock,
violating virtio serialization rules.
The race has been there from day 1, but it got especially nasty in 3.0
when commit a5c262c5fd83ece01bd649fb08416c501d4c59d7
"virtio_ring: support event idx feature"
added more dependency on vq state.

Please review, and consider for 3.11 and stable.

Changes from v1:
	- Added Jason's Tested-by tag
	- minor coding style fix
