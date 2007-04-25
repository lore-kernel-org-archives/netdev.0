From: David Howells <dhowells@redhat.com>
Subject: [PATCH 13/16] commit ad495d7b6cfcd1bc2eaf06c42699be0bb5d84234 [try #3]
Date: Wed, 25 Apr 2007 11:51:44 +0100
Message-ID: <20070425105144.10872.72648.stgit@warthog.cambridge.redhat.com>
References: <20070425105036.10872.48596.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070425105036.10872.48596.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NETLINK]: Mirror UDP MSG_TRUNC semantics.

    If the user passes MSG_TRUNC in via msg_flags, return
    the full packet size not the truncated size.

    Idea from Herbert Xu and Thomas Graf.

    Signed-off-by: David S. Miller <davem@davemloft.net>
---

 net/netlink/af_netlink.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c48b0f4..5890210 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1242,6 +1242,9 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 
 	scm_recv(sock, msg, siocb->scm, flags);
 
+	if (flags & MSG_TRUNC)
+		copied = skb->len;
+
 out:
 	netlink_rcv_wake(sk);
 	return err ? : copied;

