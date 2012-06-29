From: Andreas Gruenbacher <agruen@linbit.com>
Subject: [RFC] [TCP 0/3] Receive from socket into bio without copying
Date: Fri, 29 Jun 2012 16:53:52 +0200
Message-ID: <1340981632.25226.2.camel@gurkel.linbit>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I'm (still) trying to pass data from the network to the block layer without
copying. The block layer needs blocks to be contiguous in memory, and may have
some alignment restrictions as well.  A lot of modern network hardware will
receive large packets into separate buffers, so individual large packets will
end up in contiguous, aligned buffers.  I would like to make use of that, but
tcp currently doesn't allow me to control what ends up in which packets.

This patch series introduces a new flag for indicating to tcp when it should
start a new segment. Using that on the sender side, I can get data over the
network with no cpu copying at all.

[My last posting on this topic from May 8 is archived here:
 http://www.spinics.net/lists/netdev/msg197788.html ]

Thanks,
Andreas

Andreas Gruenbacher (3):
  tcp: Add MSG_NEW_PACKET flag to indicate preferable packet boundaries
  tcp: Zero-copy receive from a socket into a bio
  fs: Export bio_release_pages()

 fs/bio.c               |    3 +-
 include/linux/bio.h    |    1 +
 include/linux/socket.h |    1 +
 include/net/tcp.h      |    3 +
 net/ipv4/Makefile      |    3 +-
 net/ipv4/tcp.c         |    5 +-
 net/ipv4/tcp_recvbio.c |  168 ++++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 180 insertions(+), 4 deletions(-)
 create mode 100644 net/ipv4/tcp_recvbio.c

-- 
1.7.10.2
