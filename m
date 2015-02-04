From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2 01/18] netlink: make the check for "send from tx_ring"
 deterministic
Date: Wed, 4 Feb 2015 06:37:30 +0000
Message-ID: <20150204063730.GG29656@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
 <1422863977-17668-1-git-send-email-viro@ZenIV.linux.org.uk>
 <54CF7828.6040605@cogentembedded.com>
 <20150203.162102.2178616439474613506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:43069 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbbBDGhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 01:37:36 -0500
Content-Disposition: inline
In-Reply-To: <20150203.162102.2178616439474613506.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2015 at 04:21:02PM -0800, David Miller wrote:
> Indeed, Al can you please audit your whole series for this issue and
> respin?

Done, will repost in followups to this one.

> Please also explicitly give me the GIT url to pull from each time you
> post the series.

OK, it's been force-pushed to
git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git for-davem

Shortlog:
Al Viro (18):
      netlink: make the check for "send from tx_ring" deterministic
      ipv4: raw_send_hdrinc(): pass msghdr
      ipv6: rawv6_send_hdrinc(): pass msghdr
      vmci: propagate msghdr all way down to __qp_memcpy_to_queue()
      rxrpc: switch rxrpc_send_data() to iov_iter primitives
      rxrpc: make the users of rxrpc_kernel_send_data() set kvec-backed msg_iter properly
      ip: stash a pointer to msghdr in struct ping_fakehdr
      ip: convert tcp_sendmsg() to iov_iter primitives
      net: switch memcpy_fromiovec()/memcpy_fromiovecend() users to copy_from_iter()
      tipc: tipc ->sendmsg() conversion
      net: bury net/core/iovec.c - nothing in there is used anymore
      crypto: switch af_alg_make_sg() to iov_iter
      net/socket.c: fold do_sock_{read,write} into callers
      net: switch sockets to ->read_iter/->write_iter
      vhost: switch vhost get_indirect() to iov_iter, kill memcpy_fromiovec()
      vhost: don't bother with copying iovec in handle_tx()
      vhost: don't bother copying iovecs in handle_rx(), kill memcpy_toiovecend()
      vhost: vhost_scsi_handle_vq() should just use copy_from_user()

Diffstat:
 crypto/af_alg.c                         |  40 ++----
 crypto/algif_hash.c                     |  45 +++---
 crypto/algif_skcipher.c                 |  74 +++++-----
 drivers/misc/vmw_vmci/vmci_queue_pair.c |  16 +--
 drivers/vhost/net.c                     |  91 ++++---------
 drivers/vhost/scsi.c                    |   2 +-
 drivers/vhost/vhost.c                   |   6 +-
 fs/afs/rxrpc.c                          |  14 +-
 include/crypto/if_alg.h                 |   3 +-
 include/linux/skbuff.h                  |  14 +-
 include/linux/socket.h                  |   7 -
 include/linux/uio.h                     |   6 -
 include/linux/vmw_vmci_api.h            |   2 +-
 include/net/ping.h                      |   2 +-
 include/net/sock.h                      |  18 ++-
 include/net/udplite.h                   |   3 +-
 lib/Makefile                            |   2 +-
 lib/iovec.c                             |  87 ------------
 net/core/Makefile                       |   2 +-
 net/core/iovec.c                        | 137 -------------------
 net/ipv4/ip_output.c                    |   6 +-
 net/ipv4/ping.c                         |  17 ++-
 net/ipv4/raw.c                          |   7 +-
 net/ipv4/tcp.c                          | 233 +++++++++++++++-----------------
 net/ipv4/tcp_output.c                   |  11 +-
 net/ipv6/ping.c                         |   3 +-
 net/ipv6/raw.c                          |   7 +-
 net/netlink/af_netlink.c                |   5 +
 net/rxrpc/ar-output.c                   |  46 ++-----
 net/socket.c                            |  76 ++++-------
 net/tipc/msg.c                          |   7 +-
 net/tipc/socket.c                       |  14 +-
 net/vmw_vsock/vmci_transport.c          |   3 +-
 33 files changed, 320 insertions(+), 686 deletions(-)
 delete mode 100644 lib/iovec.c
 delete mode 100644 net/core/iovec.c
