From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [resend take 2 0/4] Distributed storage.
Date: Mon, 17 Nov 2008 22:21:35 +0300
Message-ID: <12269496993020-git-send-email-zbr@ioremap.net>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zbr.yandex.ru ([213.180.219.33]:59146 "EHLO gavana.yandex.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751760AbYKQT2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 14:28:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Distributed storage is a feature-rich network block device.

Supported features:

    * Kernel-side client and server. No need for any special tools for data processing
    	(like special userspace applications) except for configuration.
    * Bullet-proof memory allocations via memory pools for all temporary objects
    	(transaction and so on). All clients structures are allocated as single transaction
	from the memory pool and except this there is no allocation overhead.
	Network adds own though. Server uses memory pools too, but number of allocations is
	higher (bio, transaction and pages for IO).
    * Zero-copy sending (except header) if supported by device using sendpage().
    * Failover recovery in case of broken link (reconnection if remote node is down).
    * Full transaction support (resending of the failed transactions on timeout of after
    	reconnect to failed node).
    * Dynamically resizeable pool of threads used for data receiving and crypto processing.
    * Initial autoconfiguration. Ability to extend it with additional attributes if needed.
    * Support for barriers and other block io request flags.
    * Support for any kind of network media (not limited to tcp or inet protocols) higher
    	MAC layer (socket layer). Out of the box kernel-side IPv6 support (needs to extend
	configuration utility, check how it was done in POHMELFS).
    * Security attributes for local export nodes (list of allowed to connect addresses
    	with permissions). Read-only connections.
    * Ability to use any supported cryptographically strong checksums.
    	Ability to encrypt data channel.
    * Keepalive messages to early detect failed nodes.

This release only contains code movement around.

One can grab sources (various configuration examples can be found in 'userspace' dir)
from archive, or via kernel and userspace GIT trees.

Consider for inclusion.
Thank you.

1. POHMELFS homepage.
http://www.ioremap.net/projects/pohmelfs

2. DST homepage.
http://www.ioremap.net/projects/dst

3. DST archive.
http://www.ioremap.net/archive/dst/

4. DST git trees.
http://www.ioremap.net/cgi-bin/gitweb.cgi

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

 drivers/block/Kconfig           |    2 +
 drivers/block/Makefile          |    2 +
 drivers/block/dst/Kconfig       |   14 +
 drivers/block/dst/Makefile      |    3 +
 drivers/block/dst/crypto.c      |  731 +++++++++++++++++++++++++++++
 drivers/block/dst/dcore.c       |  973 +++++++++++++++++++++++++++++++++++++++
 drivers/block/dst/export.c      |  664 ++++++++++++++++++++++++++
 drivers/block/dst/state.c       |  839 +++++++++++++++++++++++++++++++++
 drivers/block/dst/thread_pool.c |  345 ++++++++++++++
 drivers/block/dst/trans.c       |  335 ++++++++++++++
 include/linux/connector.h       |    4 +-
 include/linux/dst.h             |  587 +++++++++++++++++++++++
 12 files changed, 4498 insertions(+), 1 deletions(-)
