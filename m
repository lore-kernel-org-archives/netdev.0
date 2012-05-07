From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL net-next] macvtap, vhost and virtio tools updates
Date: Mon, 7 May 2012 23:55:39 +0300
Message-ID: <20120507205537.GA27950@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org, jasowang@redhat.com,
	mst@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are mostly bugfixes here.
I hope to merge some more patches by 3.5, in particular
vlan support fixes are waiting for Eric's ack,
and a version of tracepoint patch might be
ready in time, but let's merge what's ready so it's testable.

This includes a ton of zerocopy fixes by Jason -
good stuff but too intrusive for 3.4 and zerocopy is experimental
anyway.

virtio supported delayed interrupt for a while now
so adding support to the virtio tool made sense

Please pull into net-next and merge for 3.5.
Thanks!

MST

The following changes since commit e4ae004b84b315dd4b762e474f97403eac70f76a:

  netem: add ECN capability (2012-05-01 09:39:48 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net-next

for you to fetch changes up to c70aa540c7a9f67add11ad3161096fb95233aa2e:

  vhost: zerocopy: poll vq in zerocopy callback (2012-05-02 18:22:25 +0300)

----------------------------------------------------------------
Jason Wang (9):
      macvtap: zerocopy: fix offset calculation when building skb
      macvtap: zerocopy: fix truesize underestimation
      macvtap: zerocopy: put page when fail to get all requested user pages
      macvtap: zerocopy: set SKBTX_DEV_ZEROCOPY only when skb is built successfully
      macvtap: zerocopy: validate vectors before building skb
      vhost_net: zerocopy: fix possible NULL pointer dereference of vq->bufs
      vhost_net: re-poll only on EAGAIN or ENOBUFS
      vhost_net: zerocopy: adding and signalling immediately when fully copied
      vhost: zerocopy: poll vq in zerocopy callback

Michael S. Tsirkin (1):
      virtio/tools: add delayed interupt mode

 drivers/net/macvtap.c       |   57 ++++++++++++++++++++++++++++++-------------
 drivers/vhost/net.c         |    7 ++++-
 drivers/vhost/vhost.c       |    1 +
 tools/virtio/linux/virtio.h |    1 +
 tools/virtio/virtio_test.c  |   26 ++++++++++++++++---
 5 files changed, 69 insertions(+), 23 deletions(-)
