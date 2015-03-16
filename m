From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH v2 net-next 0/4] Add support for async socket operations
Date: Mon, 16 Mar 2015 09:15:08 -0700
Message-ID: <20150316161508.16418.23674.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-aio@kvack.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, ying.xue@windriver.com, bcrl@kvack.org,
	viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-crypto@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:27002 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933315AbbCPQRo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2015 12:17:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the iocb parameter has been removed from sendmsg() and recvmsg() ops
the socket layer, and the network stack no longer support async operations.
This patch set adds support for asynchronous operations on sockets back.

--
Tadeusz Struk (4):
      net: socket: add support for async operations
      aio: prefer aio_op op over inter_op
      crypto: af_alg - Allow to link sgl
      crypto: algif - change algif_skcipher to be asynchronous

Changes in v2:
* removed redundant total_size param from aio_sendmsg and aio_recvmsg functions

 crypto/af_alg.c         |   18 +++-
 crypto/algif_skcipher.c |  224 ++++++++++++++++++++++++++++++++++++++++++++++-
 fs/aio.c                |    8 +-
 include/crypto/if_alg.h |    4 +
 include/linux/net.h     |    5 +
 net/socket.c            |   63 +++++++++++++
 6 files changed, 308 insertions(+), 14 deletions(-)
-- 
