From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH v3 net-next 0/3] Add support for async socket operations
Date: Thu, 19 Mar 2015 12:31:19 -0700
Message-ID: <20150319193118.11500.10463.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-aio@kvack.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, ying.xue@windriver.com, bcrl@kvack.org,
	viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-crypto@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After the iocb parameter has been removed from sendmsg() and recvmsg() ops
the socket layer, and the network stack no longer support async operations.
This patch set adds support for asynchronous operations on sockets back.

Changes in v3:
* As sugested by Al Viro instead of adding new functions aio_sendmsg
  and aio_recvmsg, added a ptr to iocb into the kernel-side msghdr structure.
  This way no change to aio.c is required.

Changes in v2:
* removed redundant total_size param from aio_sendmsg and aio_recvmsg functions

--
Tadeusz Struk (3):
      net: socket: add support for async operations
      crypto: af_alg - Allow to link sgl
      crypto: algif - change algif_skcipher to be asynchronous


 crypto/af_alg.c         |   18 +++-
 crypto/algif_skcipher.c |  233 ++++++++++++++++++++++++++++++++++++++++++++++-
 include/crypto/if_alg.h |    4 +
 include/linux/socket.h  |    1 
 net/compat.c            |    2 
 net/socket.c            |    8 +-
 6 files changed, 251 insertions(+), 15 deletions(-)

-- 
