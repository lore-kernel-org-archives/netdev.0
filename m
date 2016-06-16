From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the vhost tree with the net-next tree
Date: Thu, 16 Jun 2016 14:19:57 +1000
Message-ID: <20160616141957.4d7582a7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael,

Today's linux-next merge of the vhost tree got a conflict in:

  tools/virtio/ringtest/Makefile

between commit:

  9fb6bc5b4a78 ("ptr_ring: ring test")

from the net-next tree and commit:

  139ab4d4e68b ("tools/virtio: add noring tool")

from the vhost tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc tools/virtio/ringtest/Makefile
index 50e086c6a7b6,6173adae9f08..000000000000
--- a/tools/virtio/ringtest/Makefile
+++ b/tools/virtio/ringtest/Makefile
@@@ -1,6 -1,6 +1,6 @@@
  all:
  
- all: ring virtio_ring_0_9 virtio_ring_poll virtio_ring_inorder ptr_ring
 -all: ring virtio_ring_0_9 virtio_ring_poll virtio_ring_inorder noring
++all: ring virtio_ring_0_9 virtio_ring_poll virtio_ring_inorder ptr_ring noring
  
  CFLAGS += -Wall
  CFLAGS += -pthread -O2 -ggdb
@@@ -16,13 -15,13 +16,15 @@@ ring: ring.o main.
  virtio_ring_0_9: virtio_ring_0_9.o main.o
  virtio_ring_poll: virtio_ring_poll.o main.o
  virtio_ring_inorder: virtio_ring_inorder.o main.o
 +ptr_ring: ptr_ring.o main.o
+ noring: noring.o main.o
  clean:
  	-rm main.o
  	-rm ring.o ring
  	-rm virtio_ring_0_9.o virtio_ring_0_9
  	-rm virtio_ring_poll.o virtio_ring_poll
  	-rm virtio_ring_inorder.o virtio_ring_inorder
 +	-rm ptr_ring.o ptr_ring
+ 	-rm noring.o noring
  
  .PHONY: all clean
