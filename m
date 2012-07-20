From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv3 0/6] tun zerocopy support
Date: Fri, 20 Jul 2012 22:23:03 +0300
Message-ID: <cover.1342812067.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds support for experimental zero copy transmit to tun.

This includes some patches from Ian's patchset to support zerocopy with tun,
so it should help that work progress: we are still trying to figure out
how to make everything work properly with tcp but tun seems easier, and
it's helpful by itself since not everyone can use macvtap.

Same as with macvtap, I get single-percentage wins in CPU utilization
on guest to external from this patchset, and a performance regression on
guest to host, so more work is needed until this feature can move out of
experimental status, but I think it's useful for some people already.

Pls review and consider for 3.6.

There's some code duplication between tun and macvtap now: common code
could move to net/core/datagram.c, this patch does not do this yet.

Changes from v2:
	Fixed some bugs so it's stable now

Michael S. Tsirkin (6):
  skbuff: add an api to orphan frags
  skbuff: convert to skb_orphan_frags
  skbuff: export skb_copy_ubufs
  tun: orphan frags on xmit
  net: orphan frags on receive
  tun: experimental zero copy tx support

 drivers/net/tun.c      | 148 +++++++++++++++++++++++++++++++++++++++++++++----
 include/linux/skbuff.h |  16 ++++++
 net/core/dev.c         |   7 ++-
 net/core/skbuff.c      |  24 +++-----
 4 files changed, 167 insertions(+), 28 deletions(-)

-- 
MST
