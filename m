From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] virtio_net: indicate oom when addbuf returns failure
Date: Fri, 4 Jun 2010 10:28:56 +0930
Message-ID: <201006041028.56798.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Bruce Rogers <brogers@novell.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:42537 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756893Ab0FDA67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jun 2010 20:58:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a subset of an already upstream patch, but this portion
is useful in earlier releases.

Please consider for the 2.6.32 and 2.6.33 stable trees.

If the add_buf operation fails, indicate failure to the caller.

Signed-off-by: Bruce Rogers <brogers@novell.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c

@@ -318,6 +318,7 @@ static bool try_fill_recv_maxbufs(struct
                        skb_unlink(skb, &vi->recv);
                        trim_pages(vi, skb);
                        kfree_skb(skb);
+                       oom = true;
                        break;
                }
                vi->num++;
@@ -368,6 +369,7 @@ static bool try_fill_recv(struct virtnet
                if (err < 0) {
                        skb_unlink(skb, &vi->recv);
                        kfree_skb(skb);
+                       oom = true;
                        break;
                }
                vi->num++;
