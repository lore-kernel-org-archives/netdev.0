From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/6] net: initialize rmem_alloc and omem_alloc to 0 in
	netlink socket
Date: Thu, 17 Sep 2009 17:57:09 -0700
Message-ID: <20090918005708.25594.52575.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	linux-scsi@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Fastabend <john.r.fastabend@intel.com>

The rmem_alloc and omem_alloc socket fields are not
initialized.  This sets each variable to zero when a socket
is created.  Note the sk_wmem_alloc is already initialized
in sock_init_data.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/netlink/af_netlink.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c5aab6a..4e673d2 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -423,6 +423,9 @@ static int __netlink_create(struct net *net, struct socket *sock,
 	}
 	init_waitqueue_head(&nlk->wait);
 
+	atomic_set(&sk->sk_rmem_alloc, 0);
+	atomic_set(&sk->sk_omem_alloc, 0);
+
 	sk->sk_destruct = netlink_sock_destruct;
 	sk->sk_protocol = protocol;
 	return 0;

