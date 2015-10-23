From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH 04/11] net: packet: change vnet_hdr_len from int to size_t
Date: Fri, 23 Oct 2015 14:10:29 +0200
Message-ID: <1445602236-24130-5-git-send-email-clabbe.montjoie@gmail.com>
References: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: al.drozdov@gmail.com, daniel@iogearbox.net, davem@davemloft.net,
	dwmw2@infradead.org, edumazet@google.com, eyal.birger@gmail.com,
	mst@redhat.com, viro@zeniv.linux.org.uk, willemb@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vnet_hdr_len cannot be negative and is use in operation/function that
wait for unsigned value.
This patch set vnet_hdr_len as size_t.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 net/packet/af_packet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index aa4b15c..58a5c8f 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2632,7 +2632,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	int err, reserve = 0;
 	struct virtio_net_hdr vnet_hdr = { 0 };
 	int offset = 0;
-	int vnet_hdr_len;
+	size_t vnet_hdr_len;
 	struct packet_sock *po = pkt_sk(sk);
 	unsigned short gso_type = 0;
 	int hlen, tlen;
@@ -3106,7 +3106,7 @@ static int packet_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
 	int copied, err;
-	int vnet_hdr_len = 0;
+	size_t vnet_hdr_len = 0;
 	unsigned int origlen = 0;
 
 	err = -EINVAL;
-- 
2.4.10
