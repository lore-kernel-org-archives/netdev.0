From: Jason Wang <jasowang@redhat.com>
Subject: [net-next 0/6] Reduce code duplication of zerocopy of tun and macvtap
Date: Tue,  6 Aug 2013 17:45:02 +0800
Message-ID: <1375782308-10565-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all:

This series tries to reduce the code duplication of zerocopy of tun and macvtap
by:

- Move common helpers iov_pages() and zerocopy_sg_from_iovec() to net/core
- Use exist helpers instead of open coding the new one

With this seires, we can do further optimizations on top.

Please review.

Jason Wang (6):
  net: move iov_pages() to net/core/iovec.c
  net: move zerocopy_sg_from_iovec() to net/core/datagram.c
  net: use skb_fill_page_desc() in zerocopy_sg_from_iovec()
  net: remove the useless comment in zerocopy_sg_from_iovec()
  net: use release_pages() in zerocopy_sg_from_iovec()
  net: use skb_copy_datagram_from_iovec() in zerocopy_sg_from_iovec()

 drivers/net/macvtap.c  |  103 ------------------------------------------------
 drivers/net/tun.c      |  103 ------------------------------------------------
 include/linux/skbuff.h |    4 ++
 include/linux/socket.h |    2 +
 net/core/datagram.c    |   72 +++++++++++++++++++++++++++++++++
 net/core/iovec.c       |   24 +++++++++++
 6 files changed, 102 insertions(+), 206 deletions(-)
