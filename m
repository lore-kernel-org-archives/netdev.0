From: Eric Paris <eparis@redhat.com>
Subject: [PATCH 3/3] net: check kern before calling security subsystem
Date: Wed, 04 Nov 2009 11:32:24 -0500
Message-ID: <20091104163224.27133.88570.stgit@paris.rdu.redhat.com>
References: <20091104163211.27133.74927.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, acme@redhat.com, dwalsh@redhat.com,
	davem@davemloft.net, linux-security-module@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091104163211.27133.74927.stgit@paris.rdu.redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Before calling capable(CAP_NET_RAW) check if this operations is on behalf
of the kernel or on behalf of userspace.  Do not do the security check if
it is on behalf of the kernel.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 net/bluetooth/l2cap.c |    2 +-
 net/ipv4/af_inet.c    |    2 +-
 net/ipv6/af_inet6.c   |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 365ae16..ff0233d 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -832,7 +832,7 @@ static int l2cap_sock_create(struct net *net, struct socket *sock, int protocol,
 			sock->type != SOCK_DGRAM && sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	if (sock->type == SOCK_RAW && !capable(CAP_NET_RAW))
+	if (sock->type == SOCK_RAW && !kern && !capable(CAP_NET_RAW))
 		return -EPERM;
 
 	sock->ops = &l2cap_sock_ops;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5c7e42c..7d12c6a 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -326,7 +326,7 @@ lookup_protocol:
 	}
 
 	err = -EPERM;
-	if (sock->type == SOCK_RAW && !capable(CAP_NET_RAW))
+	if (sock->type == SOCK_RAW && !kern && !capable(CAP_NET_RAW))
 		goto out_rcu_unlock;
 
 	err = -EAFNOSUPPORT;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 45ed5e0..12e69d3 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -159,7 +159,7 @@ lookup_protocol:
 	}
 
 	err = -EPERM;
-	if (sock->type == SOCK_RAW && !capable(CAP_NET_RAW))
+	if (sock->type == SOCK_RAW && !kern && !capable(CAP_NET_RAW))
 		goto out_rcu_unlock;
 
 	sock->ops = answer->ops;

