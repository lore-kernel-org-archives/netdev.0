From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 3/6] net: Pass kern from net_proto_family.create to sk_alloc
Date: Fri, 08 May 2015 21:09:13 -0500
Message-ID: <87ioc21oza.fsf_-_@x220.int.ebiederm.org>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<20150508140733.GA13325@gondor.apana.org.au>
	<87sib76kef.fsf@x220.int.ebiederm.org>
	<20150509011339.GA19116@gondor.apana.org.au>
	<87383633pu.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ying Xue <ying.xue@windriver.com>, netdev@vger.kernel.org,
	cwang@twopensource.com, xemul@openvz.org, eric.dumazet@gmail.com,
	maxk@qti.qualcomm.com, stephen@networkplumber.org, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, tom@herbertland.com,
	jchapman@katalix.com, erik.hugne@ericsson.com,
	jon.maloy@ericsson.com, horms@verge.net.au,
	Herbert Xu <herbert@gondor.apana.org.au>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:34801 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbbEICNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 22:13:50 -0400
In-Reply-To: <87383633pu.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 08 May 2015 21:05:33 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In preparation for changing how struct net is refcounted
on kernel sockets pass the knowledge that we are creating
a kernel socket from sock_create_kern through to sk_alloc.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 crypto/af_alg.c                |  4 ++--
 drivers/isdn/mISDN/socket.c    | 12 ++++++------
 drivers/net/macvtap.c          |  2 +-
 drivers/net/ppp/pppoe.c        |  4 ++--
 drivers/net/ppp/pppox.c        |  2 +-
 drivers/net/ppp/pptp.c         |  4 ++--
 drivers/net/tun.c              |  2 +-
 include/linux/if_pppox.h       |  2 +-
 include/net/af_vsock.h         |  2 +-
 include/net/llc_conn.h         |  2 +-
 include/net/sock.h             |  2 +-
 net/appletalk/ddp.c            |  2 +-
 net/atm/common.c               |  4 ++--
 net/atm/common.h               |  2 +-
 net/atm/pvc.c                  |  2 +-
 net/atm/svc.c                  |  2 +-
 net/ax25/af_ax25.c             |  4 ++--
 net/bluetooth/bnep/sock.c      |  2 +-
 net/bluetooth/cmtp/sock.c      |  2 +-
 net/bluetooth/hci_sock.c       |  2 +-
 net/bluetooth/hidp/sock.c      |  2 +-
 net/bluetooth/l2cap_sock.c     | 10 +++++-----
 net/bluetooth/rfcomm/sock.c    |  8 ++++----
 net/bluetooth/sco.c            |  8 ++++----
 net/caif/caif_socket.c         |  2 +-
 net/can/af_can.c               |  2 +-
 net/core/sock.c                |  3 ++-
 net/decnet/af_decnet.c         |  8 ++++----
 net/ieee802154/socket.c        |  2 +-
 net/ipv4/af_inet.c             |  2 +-
 net/ipv6/af_inet6.c            |  2 +-
 net/ipx/af_ipx.c               |  2 +-
 net/irda/af_irda.c             |  2 +-
 net/iucv/af_iucv.c             | 10 +++++-----
 net/key/af_key.c               |  2 +-
 net/l2tp/l2tp_ppp.c            |  4 ++--
 net/llc/af_llc.c               |  2 +-
 net/llc/llc_conn.c             |  6 +++---
 net/netlink/af_netlink.c       | 11 +++++------
 net/netrom/af_netrom.c         |  4 ++--
 net/nfc/af_nfc.c               |  2 +-
 net/nfc/llcp.h                 |  2 +-
 net/nfc/llcp_core.c            |  2 +-
 net/nfc/llcp_sock.c            |  8 ++++----
 net/nfc/nfc.h                  |  2 +-
 net/nfc/rawsock.c              |  4 ++--
 net/packet/af_packet.c         |  2 +-
 net/phonet/af_phonet.c         |  2 +-
 net/phonet/pep.c               |  2 +-
 net/rds/af_rds.c               |  2 +-
 net/rose/af_rose.c             |  4 ++--
 net/rxrpc/af_rxrpc.c           |  2 +-
 net/sctp/ipv6.c                |  2 +-
 net/sctp/protocol.c            |  2 +-
 net/tipc/socket.c              |  2 +-
 net/unix/af_unix.c             |  8 ++++----
 net/vmw_vsock/af_vsock.c       |  7 ++++---
 net/vmw_vsock/vmci_transport.c |  2 +-
 net/x25/af_x25.c               |  8 ++++----
 59 files changed, 109 insertions(+), 108 deletions(-)

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index f22cc56fd1b3..5ad0d5354535 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -244,7 +244,7 @@ int af_alg_accept(struct sock *sk, struct socket *newsock)
 	if (!type)
 		goto unlock;
 
-	sk2 = sk_alloc(sock_net(sk), PF_ALG, GFP_KERNEL, &alg_proto);
+	sk2 = sk_alloc(sock_net(sk), PF_ALG, GFP_KERNEL, &alg_proto, 0);
 	err = -ENOMEM;
 	if (!sk2)
 		goto unlock;
@@ -324,7 +324,7 @@ static int alg_create(struct net *net, struct socket *sock, int protocol,
 		return -EPROTONOSUPPORT;
 
 	err = -ENOMEM;
-	sk = sk_alloc(net, PF_ALG, GFP_KERNEL, &alg_proto);
+	sk = sk_alloc(net, PF_ALG, GFP_KERNEL, &alg_proto, kern);
 	if (!sk)
 		goto out;
 
diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 8dc7290089bb..0d29b5a6356d 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -601,14 +601,14 @@ static const struct proto_ops data_sock_ops = {
 };
 
 static int
-data_sock_create(struct net *net, struct socket *sock, int protocol)
+data_sock_create(struct net *net, struct socket *sock, int protocol, int kern)
 {
 	struct sock *sk;
 
 	if (sock->type != SOCK_DGRAM)
 		return -ESOCKTNOSUPPORT;
 
-	sk = sk_alloc(net, PF_ISDN, GFP_KERNEL, &mISDN_proto);
+	sk = sk_alloc(net, PF_ISDN, GFP_KERNEL, &mISDN_proto, kern);
 	if (!sk)
 		return -ENOMEM;
 
@@ -756,14 +756,14 @@ static const struct proto_ops base_sock_ops = {
 
 
 static int
-base_sock_create(struct net *net, struct socket *sock, int protocol)
+base_sock_create(struct net *net, struct socket *sock, int protocol, int kern)
 {
 	struct sock *sk;
 
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	sk = sk_alloc(net, PF_ISDN, GFP_KERNEL, &mISDN_proto);
+	sk = sk_alloc(net, PF_ISDN, GFP_KERNEL, &mISDN_proto, kern);
 	if (!sk)
 		return -ENOMEM;
 
@@ -785,7 +785,7 @@ mISDN_sock_create(struct net *net, struct socket *sock, int proto, int kern)
 
 	switch (proto) {
 	case ISDN_P_BASE:
-		err = base_sock_create(net, sock, proto);
+		err = base_sock_create(net, sock, proto, kern);
 		break;
 	case ISDN_P_TE_S0:
 	case ISDN_P_NT_S0:
@@ -799,7 +799,7 @@ mISDN_sock_create(struct net *net, struct socket *sock, int proto, int kern)
 	case ISDN_P_B_L2DTMF:
 	case ISDN_P_B_L2DSP:
 	case ISDN_P_B_L2DSPHDLC:
-		err = data_sock_create(net, sock, proto);
+		err = data_sock_create(net, sock, proto, kern);
 		break;
 	default:
 		return err;
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 8c350c5d54ad..0398631a3c24 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -476,7 +476,7 @@ static int macvtap_open(struct inode *inode, struct file *file)
 
 	err = -ENOMEM;
 	q = (struct macvtap_queue *)sk_alloc(net, AF_UNSPEC, GFP_KERNEL,
-					     &macvtap_proto);
+					     &macvtap_proto, 0);
 	if (!q)
 		goto out;
 
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index aa1dd926623a..f86c5ab334aa 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -546,11 +546,11 @@ static struct proto pppoe_sk_proto __read_mostly = {
  * Initialize a new struct sock.
  *
  **********************************************************************/
-static int pppoe_create(struct net *net, struct socket *sock)
+static int pppoe_create(struct net *net, struct socket *sock, int kern)
 {
 	struct sock *sk;
 
-	sk = sk_alloc(net, PF_PPPOX, GFP_KERNEL, &pppoe_sk_proto);
+	sk = sk_alloc(net, PF_PPPOX, GFP_KERNEL, &pppoe_sk_proto, kern);
 	if (!sk)
 		return -ENOMEM;
 
diff --git a/drivers/net/ppp/pppox.c b/drivers/net/ppp/pppox.c
index 2940e9fe351b..0e1b30622477 100644
--- a/drivers/net/ppp/pppox.c
+++ b/drivers/net/ppp/pppox.c
@@ -118,7 +118,7 @@ static int pppox_create(struct net *net, struct socket *sock, int protocol,
 	    !try_module_get(pppox_protos[protocol]->owner))
 		goto out;
 
-	rc = pppox_protos[protocol]->create(net, sock);
+	rc = pppox_protos[protocol]->create(net, sock, kern);
 
 	module_put(pppox_protos[protocol]->owner);
 out:
diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index e3bfbd4d0136..14839bc0aaf5 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -561,14 +561,14 @@ static void pptp_sock_destruct(struct sock *sk)
 	skb_queue_purge(&sk->sk_receive_queue);
 }
 
-static int pptp_create(struct net *net, struct socket *sock)
+static int pptp_create(struct net *net, struct socket *sock, int kern)
 {
 	int error = -ENOMEM;
 	struct sock *sk;
 	struct pppox_sock *po;
 	struct pptp_opt *opt;
 
-	sk = sk_alloc(net, PF_PPPOX, GFP_KERNEL, &pptp_sk_proto);
+	sk = sk_alloc(net, PF_PPPOX, GFP_KERNEL, &pptp_sk_proto, kern);
 	if (!sk)
 		goto out;
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3262f3e2b8b2..1a1c4f7b3ec5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -2148,7 +2148,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 	DBG1(KERN_INFO, "tunX: tun_chr_open\n");
 
 	tfile = (struct tun_file *)sk_alloc(net, AF_UNSPEC, GFP_KERNEL,
-					    &tun_proto);
+					    &tun_proto, 0);
 	if (!tfile)
 		return -ENOMEM;
 	RCU_INIT_POINTER(tfile->tun, NULL);
diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index 66a7d7600f43..b49cf923becc 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -74,7 +74,7 @@ static inline struct sock *sk_pppox(struct pppox_sock *po)
 struct module;
 
 struct pppox_proto {
-	int		(*create)(struct net *net, struct socket *sock);
+	int		(*create)(struct net *net, struct socket *sock, int kern);
 	int		(*ioctl)(struct socket *sock, unsigned int cmd,
 				 unsigned long arg);
 	struct module	*owner;
diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index 172632dd9930..db639a4c5ab8 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -74,7 +74,7 @@ void vsock_pending_work(struct work_struct *work);
 struct sock *__vsock_create(struct net *net,
 			    struct socket *sock,
 			    struct sock *parent,
-			    gfp_t priority, unsigned short type);
+			    gfp_t priority, unsigned short type, int kern);
 
 /**** TRANSPORT ****/
 
diff --git a/include/net/llc_conn.h b/include/net/llc_conn.h
index 0134681acc4c..fe994d2e5286 100644
--- a/include/net/llc_conn.h
+++ b/include/net/llc_conn.h
@@ -96,7 +96,7 @@ static __inline__ char llc_backlog_type(struct sk_buff *skb)
 }
 
 struct sock *llc_sk_alloc(struct net *net, int family, gfp_t priority,
-			  struct proto *prot);
+			  struct proto *prot, int kern);
 void llc_sk_free(struct sock *sk);
 
 void llc_sk_reset(struct sock *sk);
diff --git a/include/net/sock.h b/include/net/sock.h
index 3a4898ec8c67..d8dcf91732b0 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1514,7 +1514,7 @@ static inline void unlock_sock_fast(struct sock *sk, bool slow)
 
 
 struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
-		      struct proto *prot);
+		      struct proto *prot, int kern);
 void sk_free(struct sock *sk);
 void sk_release_kernel(struct sock *sk);
 struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority);
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 3b7ad43c7dad..d5871ac493eb 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1030,7 +1030,7 @@ static int atalk_create(struct net *net, struct socket *sock, int protocol,
 	if (sock->type != SOCK_RAW && sock->type != SOCK_DGRAM)
 		goto out;
 	rc = -ENOMEM;
-	sk = sk_alloc(net, PF_APPLETALK, GFP_KERNEL, &ddp_proto);
+	sk = sk_alloc(net, PF_APPLETALK, GFP_KERNEL, &ddp_proto, kern);
 	if (!sk)
 		goto out;
 	rc = 0;
diff --git a/net/atm/common.c b/net/atm/common.c
index ed0466637e13..49a872db7e42 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -141,7 +141,7 @@ static struct proto vcc_proto = {
 	.release_cb = vcc_release_cb,
 };
 
-int vcc_create(struct net *net, struct socket *sock, int protocol, int family)
+int vcc_create(struct net *net, struct socket *sock, int protocol, int family, int kern)
 {
 	struct sock *sk;
 	struct atm_vcc *vcc;
@@ -149,7 +149,7 @@ int vcc_create(struct net *net, struct socket *sock, int protocol, int family)
 	sock->sk = NULL;
 	if (sock->type == SOCK_STREAM)
 		return -EINVAL;
-	sk = sk_alloc(net, family, GFP_KERNEL, &vcc_proto);
+	sk = sk_alloc(net, family, GFP_KERNEL, &vcc_proto, kern);
 	if (!sk)
 		return -ENOMEM;
 	sock_init_data(sock, sk);
diff --git a/net/atm/common.h b/net/atm/common.h
index 4d6f5b2068ac..959436b87182 100644
--- a/net/atm/common.h
+++ b/net/atm/common.h
@@ -10,7 +10,7 @@
 #include <linux/poll.h> /* for poll_table */
 
 
-int vcc_create(struct net *net, struct socket *sock, int protocol, int family);
+int vcc_create(struct net *net, struct socket *sock, int protocol, int family, int kern);
 int vcc_release(struct socket *sock);
 int vcc_connect(struct socket *sock, int itf, short vpi, int vci);
 int vcc_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
diff --git a/net/atm/pvc.c b/net/atm/pvc.c
index ae0324021407..040207ec399f 100644
--- a/net/atm/pvc.c
+++ b/net/atm/pvc.c
@@ -136,7 +136,7 @@ static int pvc_create(struct net *net, struct socket *sock, int protocol,
 		return -EAFNOSUPPORT;
 
 	sock->ops = &pvc_proto_ops;
-	return vcc_create(net, sock, protocol, PF_ATMPVC);
+	return vcc_create(net, sock, protocol, PF_ATMPVC, kern);
 }
 
 static const struct net_proto_family pvc_family_ops = {
diff --git a/net/atm/svc.c b/net/atm/svc.c
index 1ba23f5018e7..3fa0a9ee98d1 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -660,7 +660,7 @@ static int svc_create(struct net *net, struct socket *sock, int protocol,
 		return -EAFNOSUPPORT;
 
 	sock->ops = &svc_proto_ops;
-	error = vcc_create(net, sock, protocol, AF_ATMSVC);
+	error = vcc_create(net, sock, protocol, AF_ATMSVC, kern);
 	if (error)
 		return error;
 	ATM_SD(sock)->local.sas_family = AF_ATMSVC;
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 330c1f4a5a0b..4273533d22b1 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -855,7 +855,7 @@ static int ax25_create(struct net *net, struct socket *sock, int protocol,
 		return -ESOCKTNOSUPPORT;
 	}
 
-	sk = sk_alloc(net, PF_AX25, GFP_ATOMIC, &ax25_proto);
+	sk = sk_alloc(net, PF_AX25, GFP_ATOMIC, &ax25_proto, kern);
 	if (sk == NULL)
 		return -ENOMEM;
 
@@ -881,7 +881,7 @@ struct sock *ax25_make_new(struct sock *osk, struct ax25_dev *ax25_dev)
 	struct sock *sk;
 	ax25_cb *ax25, *oax25;
 
-	sk = sk_alloc(sock_net(osk), PF_AX25, GFP_ATOMIC,	osk->sk_prot);
+	sk = sk_alloc(sock_net(osk), PF_AX25, GFP_ATOMIC, osk->sk_prot, 0);
 	if (sk == NULL)
 		return NULL;
 
diff --git a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
index bde2bdd9e929..b5116fa9835e 100644
--- a/net/bluetooth/bnep/sock.c
+++ b/net/bluetooth/bnep/sock.c
@@ -202,7 +202,7 @@ static int bnep_sock_create(struct net *net, struct socket *sock, int protocol,
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	sk = sk_alloc(net, PF_BLUETOOTH, GFP_ATOMIC, &bnep_proto);
+	sk = sk_alloc(net, PF_BLUETOOTH, GFP_ATOMIC, &bnep_proto, kern);
 	if (!sk)
 		return -ENOMEM;
 
diff --git a/net/bluetooth/cmtp/sock.c b/net/bluetooth/cmtp/sock.c
index d82787d417bd..ce86a7bae844 100644
--- a/net/bluetooth/cmtp/sock.c
+++ b/net/bluetooth/cmtp/sock.c
@@ -205,7 +205,7 @@ static int cmtp_sock_create(struct net *net, struct socket *sock, int protocol,
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	sk = sk_alloc(net, PF_BLUETOOTH, GFP_ATOMIC, &cmtp_proto);
+	sk = sk_alloc(net, PF_BLUETOOTH, GFP_ATOMIC, &cmtp_proto, kern);
 	if (!sk)
 		return -ENOMEM;
 
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 56f9edbf3d05..5b14dcafcd08 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -1377,7 +1377,7 @@ static int hci_sock_create(struct net *net, struct socket *sock, int protocol,
 
 	sock->ops = &hci_sock_ops;
 
-	sk = sk_alloc(net, PF_BLUETOOTH, GFP_ATOMIC, &hci_sk_proto);
+	sk = sk_alloc(net, PF_BLUETOOTH, GFP_ATOMIC, &hci_sk_proto, kern);
 	if (!sk)
 		return -ENOMEM;
 
diff --git a/net/bluetooth/hidp/sock.c b/net/bluetooth/hidp/sock.c
index cb3fdde1968a..008ba439bd62 100644
--- a/net/bluetooth/hidp/sock.c
+++ b/net/bluetooth/hidp/sock.c
@@ -235,7 +235,7 @@ static int hidp_sock_create(struct net *net, struct socket *sock, int protocol,
 	if (sock->type != SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
 
-	sk = sk_alloc(net, PF_BLUETOOTH, GFP_ATOMIC, &hidp_proto);
+	sk = sk_alloc(net, PF_BLUETOOTH, GFP_ATOMIC, &hidp_proto, kern);
 	if (!sk)
 		return -ENOMEM;
 
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index a7278f05eafb..244287706f91 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -43,7 +43,7 @@ static struct bt_sock_list l2cap_sk_list = {
 static const struct proto_ops l2cap_sock_ops;
 static void l2cap_sock_init(struct sock *sk, struct sock *parent);
 static struct sock *l2cap_sock_alloc(struct net *net, struct socket *sock,
-				     int proto, gfp_t prio);
+				     int proto, gfp_t prio, int kern);
 
 bool l2cap_is_socket(struct socket *sock)
 {
@@ -1193,7 +1193,7 @@ static struct l2cap_chan *l2cap_sock_new_connection_cb(struct l2cap_chan *chan)
 	}
 
 	sk = l2cap_sock_alloc(sock_net(parent), NULL, BTPROTO_L2CAP,
-			      GFP_ATOMIC);
+			      GFP_ATOMIC, 0);
 	if (!sk) {
 		release_sock(parent);
 		return NULL;
@@ -1523,12 +1523,12 @@ static struct proto l2cap_proto = {
 };
 
 static struct sock *l2cap_sock_alloc(struct net *net, struct socket *sock,
-				     int proto, gfp_t prio)
+				     int proto, gfp_t prio, int kern)
 {
 	struct sock *sk;
 	struct l2cap_chan *chan;
 
-	sk = sk_alloc(net, PF_BLUETOOTH, prio, &l2cap_proto);
+	sk = sk_alloc(net, PF_BLUETOOTH, prio, &l2cap_proto, kern);
 	if (!sk)
 		return NULL;
 
@@ -1574,7 +1574,7 @@ static int l2cap_sock_create(struct net *net, struct socket *sock, int protocol,
 
 	sock->ops = &l2cap_sock_ops;
 
-	sk = l2cap_sock_alloc(net, sock, protocol, GFP_ATOMIC);
+	sk = l2cap_sock_alloc(net, sock, protocol, GFP_ATOMIC, kern);
 	if (!sk)
 		return -ENOMEM;
 
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 825e8fb5114b..b2338e971b33 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -269,12 +269,12 @@ static struct proto rfcomm_proto = {
 	.obj_size	= sizeof(struct rfcomm_pinfo)
 };
 
-static struct sock *rfcomm_sock_alloc(struct net *net, struct socket *sock, int proto, gfp_t prio)
+static struct sock *rfcomm_sock_alloc(struct net *net, struct socket *sock, int proto, gfp_t prio, int kern)
 {
 	struct rfcomm_dlc *d;
 	struct sock *sk;
 
-	sk = sk_alloc(net, PF_BLUETOOTH, prio, &rfcomm_proto);
+	sk = sk_alloc(net, PF_BLUETOOTH, prio, &rfcomm_proto, kern);
 	if (!sk)
 		return NULL;
 
@@ -324,7 +324,7 @@ static int rfcomm_sock_create(struct net *net, struct socket *sock,
 
 	sock->ops = &rfcomm_sock_ops;
 
-	sk = rfcomm_sock_alloc(net, sock, protocol, GFP_ATOMIC);
+	sk = rfcomm_sock_alloc(net, sock, protocol, GFP_ATOMIC, kern);
 	if (!sk)
 		return -ENOMEM;
 
@@ -969,7 +969,7 @@ int rfcomm_connect_ind(struct rfcomm_session *s, u8 channel, struct rfcomm_dlc *
 		goto done;
 	}
 
-	sk = rfcomm_sock_alloc(sock_net(parent), NULL, BTPROTO_RFCOMM, GFP_ATOMIC);
+	sk = rfcomm_sock_alloc(sock_net(parent), NULL, BTPROTO_RFCOMM, GFP_ATOMIC, 0);
 	if (!sk)
 		goto done;
 
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 4322c833e748..6b6e59dc54cf 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -460,11 +460,11 @@ static struct proto sco_proto = {
 	.obj_size	= sizeof(struct sco_pinfo)
 };
 
-static struct sock *sco_sock_alloc(struct net *net, struct socket *sock, int proto, gfp_t prio)
+static struct sock *sco_sock_alloc(struct net *net, struct socket *sock, int proto, gfp_t prio, int kern)
 {
 	struct sock *sk;
 
-	sk = sk_alloc(net, PF_BLUETOOTH, prio, &sco_proto);
+	sk = sk_alloc(net, PF_BLUETOOTH, prio, &sco_proto, kern);
 	if (!sk)
 		return NULL;
 
@@ -501,7 +501,7 @@ static int sco_sock_create(struct net *net, struct socket *sock, int protocol,
 
 	sock->ops = &sco_sock_ops;
 
-	sk = sco_sock_alloc(net, sock, protocol, GFP_ATOMIC);
+	sk = sco_sock_alloc(net, sock, protocol, GFP_ATOMIC, kern);
 	if (!sk)
 		return -ENOMEM;
 
@@ -1026,7 +1026,7 @@ static void sco_conn_ready(struct sco_conn *conn)
 		bh_lock_sock(parent);
 
 		sk = sco_sock_alloc(sock_net(parent), NULL,
-				    BTPROTO_SCO, GFP_ATOMIC);
+				    BTPROTO_SCO, GFP_ATOMIC, 0);
 		if (!sk) {
 			bh_unlock_sock(parent);
 			sco_conn_unlock(conn);
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 4ec0c803aef1..78a04ebb113c 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -1047,7 +1047,7 @@ static int caif_create(struct net *net, struct socket *sock, int protocol,
 	 * is really not used at all in the net/core or socket.c but the
 	 * initialization makes sure that sock->state is not uninitialized.
 	 */
-	sk = sk_alloc(net, PF_CAIF, GFP_KERNEL, &prot);
+	sk = sk_alloc(net, PF_CAIF, GFP_KERNEL, &prot, kern);
 	if (!sk)
 		return -ENOMEM;
 
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 32d710eaf1fc..d4d404bdfc9a 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -179,7 +179,7 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
 
 	sock->ops = cp->ops;
 
-	sk = sk_alloc(net, PF_CAN, GFP_KERNEL, cp->prot);
+	sk = sk_alloc(net, PF_CAN, GFP_KERNEL, cp->prot, kern);
 	if (!sk) {
 		err = -ENOMEM;
 		goto errout;
diff --git a/net/core/sock.c b/net/core/sock.c
index e891bcf325ca..cbc3789b830c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1396,9 +1396,10 @@ EXPORT_SYMBOL_GPL(sock_update_netprioidx);
  *	@family: protocol family
  *	@priority: for allocation (%GFP_KERNEL, %GFP_ATOMIC, etc)
  *	@prot: struct proto associated with this new sock instance
+ *	@kern: is this to be a kernel socket?
  */
 struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
-		      struct proto *prot)
+		      struct proto *prot, int kern)
 {
 	struct sock *sk;
 
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 754484b3cd0e..675cf94e04f8 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -468,10 +468,10 @@ static struct proto dn_proto = {
 	.obj_size		= sizeof(struct dn_sock),
 };
 
-static struct sock *dn_alloc_sock(struct net *net, struct socket *sock, gfp_t gfp)
+static struct sock *dn_alloc_sock(struct net *net, struct socket *sock, gfp_t gfp, int kern)
 {
 	struct dn_scp *scp;
-	struct sock *sk = sk_alloc(net, PF_DECnet, gfp, &dn_proto);
+	struct sock *sk = sk_alloc(net, PF_DECnet, gfp, &dn_proto, kern);
 
 	if  (!sk)
 		goto out;
@@ -693,7 +693,7 @@ static int dn_create(struct net *net, struct socket *sock, int protocol,
 	}
 
 
-	if ((sk = dn_alloc_sock(net, sock, GFP_KERNEL)) == NULL)
+	if ((sk = dn_alloc_sock(net, sock, GFP_KERNEL, kern)) == NULL)
 		return -ENOBUFS;
 
 	sk->sk_protocol = protocol;
@@ -1096,7 +1096,7 @@ static int dn_accept(struct socket *sock, struct socket *newsock, int flags)
 
 	cb = DN_SKB_CB(skb);
 	sk->sk_ack_backlog--;
-	newsk = dn_alloc_sock(sock_net(sk), newsock, sk->sk_allocation);
+	newsk = dn_alloc_sock(sock_net(sk), newsock, sk->sk_allocation, 0);
 	if (newsk == NULL) {
 		release_sock(sk);
 		kfree_skb(skb);
diff --git a/net/ieee802154/socket.c b/net/ieee802154/socket.c
index b60c65f70346..7aaaf967df58 100644
--- a/net/ieee802154/socket.c
+++ b/net/ieee802154/socket.c
@@ -1014,7 +1014,7 @@ static int ieee802154_create(struct net *net, struct socket *sock,
 	}
 
 	rc = -ENOMEM;
-	sk = sk_alloc(net, PF_IEEE802154, GFP_KERNEL, proto);
+	sk = sk_alloc(net, PF_IEEE802154, GFP_KERNEL, proto, kern);
 	if (!sk)
 		goto out;
 	rc = 0;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 09f4d024dfe5..e2dd9cb99d61 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -317,7 +317,7 @@ lookup_protocol:
 	WARN_ON(!answer_prot->slab);
 
 	err = -ENOBUFS;
-	sk = sk_alloc(net, PF_INET, GFP_KERNEL, answer_prot);
+	sk = sk_alloc(net, PF_INET, GFP_KERNEL, answer_prot, kern);
 	if (!sk)
 		goto out;
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 4632afa57e05..f3866c0b6cfe 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -167,7 +167,7 @@ lookup_protocol:
 	WARN_ON(!answer_prot->slab);
 
 	err = -ENOBUFS;
-	sk = sk_alloc(net, PF_INET6, GFP_KERNEL, answer_prot);
+	sk = sk_alloc(net, PF_INET6, GFP_KERNEL, answer_prot, kern);
 	if (!sk)
 		goto out;
 
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 4ea5d7497b5f..48d0dc89b58d 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1347,7 +1347,7 @@ static int ipx_create(struct net *net, struct socket *sock, int protocol,
 		goto out;
 
 	rc = -ENOMEM;
-	sk = sk_alloc(net, PF_IPX, GFP_KERNEL, &ipx_proto);
+	sk = sk_alloc(net, PF_IPX, GFP_KERNEL, &ipx_proto, kern);
 	if (!sk)
 		goto out;
 
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index ee0ea25c8e7a..fae6822cc367 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1100,7 +1100,7 @@ static int irda_create(struct net *net, struct socket *sock, int protocol,
 	}
 
 	/* Allocate networking socket */
-	sk = sk_alloc(net, PF_IRDA, GFP_KERNEL, &irda_proto);
+	sk = sk_alloc(net, PF_IRDA, GFP_KERNEL, &irda_proto, kern);
 	if (sk == NULL)
 		return -ENOMEM;
 
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 6daa52a18d40..918151c11348 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -535,12 +535,12 @@ static void iucv_sock_init(struct sock *sk, struct sock *parent)
 		sk->sk_type = parent->sk_type;
 }
 
-static struct sock *iucv_sock_alloc(struct socket *sock, int proto, gfp_t prio)
+static struct sock *iucv_sock_alloc(struct socket *sock, int proto, gfp_t prio, int kern)
 {
 	struct sock *sk;
 	struct iucv_sock *iucv;
 
-	sk = sk_alloc(&init_net, PF_IUCV, prio, &iucv_proto);
+	sk = sk_alloc(&init_net, PF_IUCV, prio, &iucv_proto, kern);
 	if (!sk)
 		return NULL;
 	iucv = iucv_sk(sk);
@@ -602,7 +602,7 @@ static int iucv_sock_create(struct net *net, struct socket *sock, int protocol,
 		return -ESOCKTNOSUPPORT;
 	}
 
-	sk = iucv_sock_alloc(sock, protocol, GFP_KERNEL);
+	sk = iucv_sock_alloc(sock, protocol, GFP_KERNEL, kern);
 	if (!sk)
 		return -ENOMEM;
 
@@ -1723,7 +1723,7 @@ static int iucv_callback_connreq(struct iucv_path *path,
 	}
 
 	/* Create the new socket */
-	nsk = iucv_sock_alloc(NULL, sk->sk_type, GFP_ATOMIC);
+	nsk = iucv_sock_alloc(NULL, sk->sk_type, GFP_ATOMIC, 0);
 	if (!nsk) {
 		err = pr_iucv->path_sever(path, user_data);
 		iucv_path_free(path);
@@ -1933,7 +1933,7 @@ static int afiucv_hs_callback_syn(struct sock *sk, struct sk_buff *skb)
 		goto out;
 	}
 
-	nsk = iucv_sock_alloc(NULL, sk->sk_type, GFP_ATOMIC);
+	nsk = iucv_sock_alloc(NULL, sk->sk_type, GFP_ATOMIC, 0);
 	bh_lock_sock(sk);
 	if ((sk->sk_state != IUCV_LISTEN) ||
 	    sk_acceptq_is_full(sk) ||
diff --git a/net/key/af_key.c b/net/key/af_key.c
index f0d52d721b3a..9e834ec475a9 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -149,7 +149,7 @@ static int pfkey_create(struct net *net, struct socket *sock, int protocol,
 		return -EPROTONOSUPPORT;
 
 	err = -ENOMEM;
-	sk = sk_alloc(net, PF_KEY, GFP_KERNEL, &key_proto);
+	sk = sk_alloc(net, PF_KEY, GFP_KERNEL, &key_proto, kern);
 	if (sk == NULL)
 		goto out;
 
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index e9b0dec56b8e..f56c9f69e9f2 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -542,12 +542,12 @@ static int pppol2tp_backlog_recv(struct sock *sk, struct sk_buff *skb)
 
 /* socket() handler. Initialize a new struct sock.
  */
-static int pppol2tp_create(struct net *net, struct socket *sock)
+static int pppol2tp_create(struct net *net, struct socket *sock, int kern)
 {
 	int error = -ENOMEM;
 	struct sock *sk;
 
-	sk = sk_alloc(net, PF_PPPOX, GFP_KERNEL, &pppol2tp_sk_proto);
+	sk = sk_alloc(net, PF_PPPOX, GFP_KERNEL, &pppol2tp_sk_proto, kern);
 	if (!sk)
 		goto out;
 
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 17a8dff06090..8fd9febaa5ba 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -168,7 +168,7 @@ static int llc_ui_create(struct net *net, struct socket *sock, int protocol,
 
 	if (likely(sock->type == SOCK_DGRAM || sock->type == SOCK_STREAM)) {
 		rc = -ENOMEM;
-		sk = llc_sk_alloc(net, PF_LLC, GFP_KERNEL, &llc_proto);
+		sk = llc_sk_alloc(net, PF_LLC, GFP_KERNEL, &llc_proto, kern);
 		if (sk) {
 			rc = 0;
 			llc_ui_sk_init(sock, sk);
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 81a61fce3afb..3e821daf9dd4 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -768,7 +768,7 @@ static struct sock *llc_create_incoming_sock(struct sock *sk,
 					     struct llc_addr *daddr)
 {
 	struct sock *newsk = llc_sk_alloc(sock_net(sk), sk->sk_family, GFP_ATOMIC,
-					  sk->sk_prot);
+					  sk->sk_prot, 0);
 	struct llc_sock *newllc, *llc = llc_sk(sk);
 
 	if (!newsk)
@@ -931,9 +931,9 @@ static void llc_sk_init(struct sock *sk)
  *	Allocates a LLC sock and initializes it. Returns the new LLC sock
  *	or %NULL if there's no memory available for one
  */
-struct sock *llc_sk_alloc(struct net *net, int family, gfp_t priority, struct proto *prot)
+struct sock *llc_sk_alloc(struct net *net, int family, gfp_t priority, struct proto *prot, int kern)
 {
-	struct sock *sk = sk_alloc(net, family, priority, prot);
+	struct sock *sk = sk_alloc(net, family, priority, prot, kern);
 
 	if (!sk)
 		goto out;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ec4adbdcb9b4..d0a82b412b24 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1117,14 +1117,15 @@ static struct proto netlink_proto = {
 };
 
 static int __netlink_create(struct net *net, struct socket *sock,
-			    struct mutex *cb_mutex, int protocol)
+			    struct mutex *cb_mutex, int protocol,
+			    int kern)
 {
 	struct sock *sk;
 	struct netlink_sock *nlk;
 
 	sock->ops = &netlink_ops;
 
-	sk = sk_alloc(net, PF_NETLINK, GFP_KERNEL, &netlink_proto);
+	sk = sk_alloc(net, PF_NETLINK, GFP_KERNEL, &netlink_proto, kern);
 	if (!sk)
 		return -ENOMEM;
 
@@ -1186,7 +1187,7 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol,
 	if (err < 0)
 		goto out;
 
-	err = __netlink_create(net, sock, cb_mutex, protocol);
+	err = __netlink_create(net, sock, cb_mutex, protocol, kern);
 	if (err < 0)
 		goto out_module;
 
@@ -2472,14 +2473,12 @@ __netlink_kernel_create(struct net *net, int unit, struct module *module,
 
 	if (sock_create_lite(PF_NETLINK, SOCK_DGRAM, unit, &sock))
 		return NULL;
-
 	/*
 	 * We have to just have a reference on the net from sk, but don't
 	 * get_net it. Besides, we cannot get and then put the net here.
 	 * So we create one inside init_net and the move it to net.
 	 */
-
-	if (__netlink_create(&init_net, sock, cb_mutex, unit) < 0)
+	if (__netlink_create(&init_net, sock, cb_mutex, unit, 0) < 0)
 		goto out_sock_release_nosk;
 
 	sk = sock->sk;
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index b987fd56c3c5..ed212ffc1d9d 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -433,7 +433,7 @@ static int nr_create(struct net *net, struct socket *sock, int protocol,
 	if (sock->type != SOCK_SEQPACKET || protocol != 0)
 		return -ESOCKTNOSUPPORT;
 
-	sk = sk_alloc(net, PF_NETROM, GFP_ATOMIC, &nr_proto);
+	sk = sk_alloc(net, PF_NETROM, GFP_ATOMIC, &nr_proto, kern);
 	if (sk  == NULL)
 		return -ENOMEM;
 
@@ -476,7 +476,7 @@ static struct sock *nr_make_new(struct sock *osk)
 	if (osk->sk_type != SOCK_SEQPACKET)
 		return NULL;
 
-	sk = sk_alloc(sock_net(osk), PF_NETROM, GFP_ATOMIC, osk->sk_prot);
+	sk = sk_alloc(sock_net(osk), PF_NETROM, GFP_ATOMIC, osk->sk_prot, 0);
 	if (sk == NULL)
 		return NULL;
 
diff --git a/net/nfc/af_nfc.c b/net/nfc/af_nfc.c
index 2277276f52bc..54e40fa47822 100644
--- a/net/nfc/af_nfc.c
+++ b/net/nfc/af_nfc.c
@@ -40,7 +40,7 @@ static int nfc_sock_create(struct net *net, struct socket *sock, int proto,
 
 	read_lock(&proto_tab_lock);
 	if (proto_tab[proto] &&	try_module_get(proto_tab[proto]->owner)) {
-		rc = proto_tab[proto]->create(net, sock, proto_tab[proto]);
+		rc = proto_tab[proto]->create(net, sock, proto_tab[proto], kern);
 		module_put(proto_tab[proto]->owner);
 	}
 	read_unlock(&proto_tab_lock);
diff --git a/net/nfc/llcp.h b/net/nfc/llcp.h
index de1789e3cc82..1f68724d44d3 100644
--- a/net/nfc/llcp.h
+++ b/net/nfc/llcp.h
@@ -225,7 +225,7 @@ void nfc_llcp_send_to_raw_sock(struct nfc_llcp_local *local,
 			       struct sk_buff *skb, u8 direction);
 
 /* Sock API */
-struct sock *nfc_llcp_sock_alloc(struct socket *sock, int type, gfp_t gfp);
+struct sock *nfc_llcp_sock_alloc(struct socket *sock, int type, gfp_t gfp, int kern);
 void nfc_llcp_sock_free(struct nfc_llcp_sock *sock);
 void nfc_llcp_accept_unlink(struct sock *sk);
 void nfc_llcp_accept_enqueue(struct sock *parent, struct sock *sk);
diff --git a/net/nfc/llcp_core.c b/net/nfc/llcp_core.c
index b18f07ccb504..98876274a1ee 100644
--- a/net/nfc/llcp_core.c
+++ b/net/nfc/llcp_core.c
@@ -934,7 +934,7 @@ static void nfc_llcp_recv_connect(struct nfc_llcp_local *local,
 		sock->ssap = ssap;
 	}
 
-	new_sk = nfc_llcp_sock_alloc(NULL, parent->sk_type, GFP_ATOMIC);
+	new_sk = nfc_llcp_sock_alloc(NULL, parent->sk_type, GFP_ATOMIC, 0);
 	if (new_sk == NULL) {
 		reason = LLCP_DM_REJ;
 		release_sock(&sock->sk);
diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index 9578bd6a4f3e..b7de0da46acd 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -942,12 +942,12 @@ static void llcp_sock_destruct(struct sock *sk)
 	}
 }
 
-struct sock *nfc_llcp_sock_alloc(struct socket *sock, int type, gfp_t gfp)
+struct sock *nfc_llcp_sock_alloc(struct socket *sock, int type, gfp_t gfp, int kern)
 {
 	struct sock *sk;
 	struct nfc_llcp_sock *llcp_sock;
 
-	sk = sk_alloc(&init_net, PF_NFC, gfp, &llcp_sock_proto);
+	sk = sk_alloc(&init_net, PF_NFC, gfp, &llcp_sock_proto, kern);
 	if (!sk)
 		return NULL;
 
@@ -993,7 +993,7 @@ void nfc_llcp_sock_free(struct nfc_llcp_sock *sock)
 }
 
 static int llcp_sock_create(struct net *net, struct socket *sock,
-			    const struct nfc_protocol *nfc_proto)
+			    const struct nfc_protocol *nfc_proto, int kern)
 {
 	struct sock *sk;
 
@@ -1009,7 +1009,7 @@ static int llcp_sock_create(struct net *net, struct socket *sock,
 	else
 		sock->ops = &llcp_sock_ops;
 
-	sk = nfc_llcp_sock_alloc(sock, sock->type, GFP_ATOMIC);
+	sk = nfc_llcp_sock_alloc(sock, sock->type, GFP_ATOMIC, kern);
 	if (sk == NULL)
 		return -ENOMEM;
 
diff --git a/net/nfc/nfc.h b/net/nfc/nfc.h
index a8ce80b47720..5c93e8412a26 100644
--- a/net/nfc/nfc.h
+++ b/net/nfc/nfc.h
@@ -30,7 +30,7 @@ struct nfc_protocol {
 	struct proto *proto;
 	struct module *owner;
 	int (*create)(struct net *net, struct socket *sock,
-		      const struct nfc_protocol *nfc_proto);
+		      const struct nfc_protocol *nfc_proto, int kern);
 };
 
 struct nfc_rawsock {
diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
index 82b4e8024778..e9a91488fe3d 100644
--- a/net/nfc/rawsock.c
+++ b/net/nfc/rawsock.c
@@ -334,7 +334,7 @@ static void rawsock_destruct(struct sock *sk)
 }
 
 static int rawsock_create(struct net *net, struct socket *sock,
-			  const struct nfc_protocol *nfc_proto)
+			  const struct nfc_protocol *nfc_proto, int kern)
 {
 	struct sock *sk;
 
@@ -348,7 +348,7 @@ static int rawsock_create(struct net *net, struct socket *sock,
 	else
 		sock->ops = &rawsock_ops;
 
-	sk = sk_alloc(net, PF_NFC, GFP_ATOMIC, nfc_proto->proto);
+	sk = sk_alloc(net, PF_NFC, GFP_ATOMIC, nfc_proto->proto, kern);
 	if (!sk)
 		return -ENOMEM;
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 5102c3cc4eec..94713276a1d9 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2832,7 +2832,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 	sock->state = SS_UNCONNECTED;
 
 	err = -ENOBUFS;
-	sk = sk_alloc(net, PF_PACKET, GFP_KERNEL, &packet_proto);
+	sk = sk_alloc(net, PF_PACKET, GFP_KERNEL, &packet_proto, kern);
 	if (sk == NULL)
 		goto out;
 
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 32ab87d34828..10d42f3220ab 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -97,7 +97,7 @@ static int pn_socket_create(struct net *net, struct socket *sock, int protocol,
 		goto out;
 	}
 
-	sk = sk_alloc(net, PF_PHONET, GFP_KERNEL, pnp->prot);
+	sk = sk_alloc(net, PF_PHONET, GFP_KERNEL, pnp->prot, kern);
 	if (sk == NULL) {
 		err = -ENOMEM;
 		goto out;
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 6de2aeb98a1f..850a86cde0b3 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -845,7 +845,7 @@ static struct sock *pep_sock_accept(struct sock *sk, int flags, int *errp)
 	}
 
 	/* Create a new to-be-accepted sock */
-	newsk = sk_alloc(sock_net(sk), PF_PHONET, GFP_KERNEL, sk->sk_prot);
+	newsk = sk_alloc(sock_net(sk), PF_PHONET, GFP_KERNEL, sk->sk_prot, 0);
 	if (!newsk) {
 		pep_reject_conn(sk, skb, PN_PIPE_ERR_OVERLOAD, GFP_KERNEL);
 		err = -ENOBUFS;
diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index 10443377fb9d..3d83641f2861 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -440,7 +440,7 @@ static int rds_create(struct net *net, struct socket *sock, int protocol,
 	if (sock->type != SOCK_SEQPACKET || protocol)
 		return -ESOCKTNOSUPPORT;
 
-	sk = sk_alloc(net, AF_RDS, GFP_ATOMIC, &rds_proto);
+	sk = sk_alloc(net, AF_RDS, GFP_ATOMIC, &rds_proto, kern);
 	if (!sk)
 		return -ENOMEM;
 
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 8ae603069a1a..36dbc2da3661 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -520,7 +520,7 @@ static int rose_create(struct net *net, struct socket *sock, int protocol,
 	if (sock->type != SOCK_SEQPACKET || protocol != 0)
 		return -ESOCKTNOSUPPORT;
 
-	sk = sk_alloc(net, PF_ROSE, GFP_ATOMIC, &rose_proto);
+	sk = sk_alloc(net, PF_ROSE, GFP_ATOMIC, &rose_proto, kern);
 	if (sk == NULL)
 		return -ENOMEM;
 
@@ -559,7 +559,7 @@ static struct sock *rose_make_new(struct sock *osk)
 	if (osk->sk_type != SOCK_SEQPACKET)
 		return NULL;
 
-	sk = sk_alloc(sock_net(osk), PF_ROSE, GFP_ATOMIC, &rose_proto);
+	sk = sk_alloc(sock_net(osk), PF_ROSE, GFP_ATOMIC, &rose_proto, 0);
 	if (sk == NULL)
 		return NULL;
 
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 0095b9a0b779..25d60ed15284 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -632,7 +632,7 @@ static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
 	sock->ops = &rxrpc_rpc_ops;
 	sock->state = SS_UNCONNECTED;
 
-	sk = sk_alloc(net, PF_RXRPC, GFP_KERNEL, &rxrpc_proto);
+	sk = sk_alloc(net, PF_RXRPC, GFP_KERNEL, &rxrpc_proto, kern);
 	if (!sk)
 		return -ENOMEM;
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 0e4198ee2370..e703ff7fed40 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -635,7 +635,7 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct sctp6_sock *newsctp6sk;
 
-	newsk = sk_alloc(sock_net(sk), PF_INET6, GFP_KERNEL, sk->sk_prot);
+	newsk = sk_alloc(sock_net(sk), PF_INET6, GFP_KERNEL, sk->sk_prot, 0);
 	if (!newsk)
 		goto out;
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 53b7acde9aa3..59e80356672b 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -550,7 +550,7 @@ static struct sock *sctp_v4_create_accept_sk(struct sock *sk,
 					     struct sctp_association *asoc)
 {
 	struct sock *newsk = sk_alloc(sock_net(sk), PF_INET, GFP_KERNEL,
-			sk->sk_prot);
+			sk->sk_prot, 0);
 	struct inet_sock *newinet;
 
 	if (!newsk)
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 9074b5cede38..8f3c8e2cef8e 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -342,7 +342,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	}
 
 	/* Allocate socket's protocol area */
-	sk = sk_alloc(net, AF_TIPC, GFP_KERNEL, &tipc_proto);
+	sk = sk_alloc(net, AF_TIPC, GFP_KERNEL, &tipc_proto, kern);
 	if (sk == NULL)
 		return -ENOMEM;
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5266ea7b922b..941b3d26e3bf 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -620,7 +620,7 @@ static struct proto unix_proto = {
  */
 static struct lock_class_key af_unix_sk_receive_queue_lock_key;
 
-static struct sock *unix_create1(struct net *net, struct socket *sock)
+static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
 {
 	struct sock *sk = NULL;
 	struct unix_sock *u;
@@ -629,7 +629,7 @@ static struct sock *unix_create1(struct net *net, struct socket *sock)
 	if (atomic_long_read(&unix_nr_socks) > 2 * get_max_files())
 		goto out;
 
-	sk = sk_alloc(net, PF_UNIX, GFP_KERNEL, &unix_proto);
+	sk = sk_alloc(net, PF_UNIX, GFP_KERNEL, &unix_proto, kern);
 	if (!sk)
 		goto out;
 
@@ -688,7 +688,7 @@ static int unix_create(struct net *net, struct socket *sock, int protocol,
 		return -ESOCKTNOSUPPORT;
 	}
 
-	return unix_create1(net, sock) ? 0 : -ENOMEM;
+	return unix_create1(net, sock, kern) ? 0 : -ENOMEM;
 }
 
 static int unix_release(struct socket *sock)
@@ -1088,7 +1088,7 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 	err = -ENOMEM;
 
 	/* create new sock for complete connection */
-	newsk = unix_create1(sock_net(sk), NULL);
+	newsk = unix_create1(sock_net(sk), NULL, 0);
 	if (newsk == NULL)
 		goto out;
 
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 2ec86e652a19..df5fc6b340f1 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -581,13 +581,14 @@ struct sock *__vsock_create(struct net *net,
 			    struct socket *sock,
 			    struct sock *parent,
 			    gfp_t priority,
-			    unsigned short type)
+			    unsigned short type,
+			    int kern)
 {
 	struct sock *sk;
 	struct vsock_sock *psk;
 	struct vsock_sock *vsk;
 
-	sk = sk_alloc(net, AF_VSOCK, priority, &vsock_proto);
+	sk = sk_alloc(net, AF_VSOCK, priority, &vsock_proto, kern);
 	if (!sk)
 		return NULL;
 
@@ -1866,7 +1867,7 @@ static int vsock_create(struct net *net, struct socket *sock,
 
 	sock->state = SS_UNCONNECTED;
 
-	return __vsock_create(net, sock, NULL, GFP_KERNEL, 0) ? 0 : -ENOMEM;
+	return __vsock_create(net, sock, NULL, GFP_KERNEL, 0, kern) ? 0 : -ENOMEM;
 }
 
 static const struct net_proto_family vsock_family_ops = {
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index c294da095461..1f63daff3965 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -1022,7 +1022,7 @@ static int vmci_transport_recv_listen(struct sock *sk,
 	}
 
 	pending = __vsock_create(sock_net(sk), NULL, sk, GFP_KERNEL,
-				 sk->sk_type);
+				 sk->sk_type, 0);
 	if (!pending) {
 		vmci_transport_send_reset(sk, pkt);
 		return -ENOMEM;
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index c3ab230e4493..a750f330b8dd 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -515,10 +515,10 @@ static struct proto x25_proto = {
 	.obj_size = sizeof(struct x25_sock),
 };
 
-static struct sock *x25_alloc_socket(struct net *net)
+static struct sock *x25_alloc_socket(struct net *net, int kern)
 {
 	struct x25_sock *x25;
-	struct sock *sk = sk_alloc(net, AF_X25, GFP_ATOMIC, &x25_proto);
+	struct sock *sk = sk_alloc(net, AF_X25, GFP_ATOMIC, &x25_proto, kern);
 
 	if (!sk)
 		goto out;
@@ -553,7 +553,7 @@ static int x25_create(struct net *net, struct socket *sock, int protocol,
 		goto out;
 
 	rc = -ENOBUFS;
-	if ((sk = x25_alloc_socket(net)) == NULL)
+	if ((sk = x25_alloc_socket(net, kern)) == NULL)
 		goto out;
 
 	x25 = x25_sk(sk);
@@ -602,7 +602,7 @@ static struct sock *x25_make_new(struct sock *osk)
 	if (osk->sk_type != SOCK_SEQPACKET)
 		goto out;
 
-	if ((sk = x25_alloc_socket(sock_net(osk))) == NULL)
+	if ((sk = x25_alloc_socket(sock_net(osk), 0)) == NULL)
 		goto out;
 
 	x25 = x25_sk(sk);
-- 
2.2.1
