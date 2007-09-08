From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 09/16] net: Initialize the network namespace of network devices.
Date: Sat, 08 Sep 2007 15:24:21 -0600
Message-ID: <m1odgcvoje.fsf_-_@ebiederm.dsl.xmission.com>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>
	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
	<m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
	<m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com>
	<m1642kx3e3.fsf_-_@ebiederm.dsl.xmission.com>
	<m11wd8x3a3.fsf_-_@ebiederm.dsl.xmission.com>
	<m1sl5ovolm.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:46780 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829AbXIHVYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2007 17:24:46 -0400
In-Reply-To: <m1sl5ovolm.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Sat, 08 Sep 2007 15:23:01 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Except for carefully selected pseudo devices all network
interfaces should start out in the initial network namespace.
Ultimately it will be register_netdev that examines what
dev->nd_net is set to and places a device in a network namespace.

This patch modifies alloc_netdev to initialize the network
namespace a device is in with the initial network namespace.
This gets it right for the vast majority of devices so their
drivers need not be modified and for those few pseudo devices
that need something different they can change this parameter
before calling register_netdevice.

The network namespace parameter on a network device is not
reference counted as the devices are inside of a network namespace
and cannot remain in that namespace past the lifetime of the
network namespace.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/dev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 2ade518..316043b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3707,6 +3707,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev = (struct net_device *)
 		(((long)p + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 	dev->padded = (char *)dev - (char *)p;
+	dev->nd_net = &init_net;
 
 	if (sizeof_priv) {
 		dev->priv = ((char *)dev +
-- 
1.5.3.rc6.17.g1911

