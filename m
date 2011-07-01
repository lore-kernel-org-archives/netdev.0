From: Joe Perches <joe@perches.com>
Subject: [PATCH 12/12] x25: Reduce switch/case indent
Date: Fri,  1 Jul 2011 12:43:13 -0700
Message-ID: <fd02aadf4bda35a8c3f775c64a0ad0785cd08998.1309549244.git.joe@perches.com>
References: <cover.1309549243.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3482 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932198Ab1GATn4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 15:43:56 -0400
In-Reply-To: <cover.1309549243.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the case labels the same indent as the switch.

git diff -w shows 80 column line reflowing.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/x25/af_x25.c   |  473 ++++++++++++++++++++++++++--------------------------
 net/x25/x25_dev.c  |   44 +++---
 net/x25/x25_in.c   |  118 +++++++-------
 net/x25/x25_link.c |   87 +++++-----
 net/x25/x25_subr.c |   78 ++++-----
 5 files changed, 397 insertions(+), 403 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 4680b1e..d306154 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -237,21 +237,21 @@ static int x25_device_event(struct notifier_block *this, unsigned long event,
 #endif
 	 ) {
 		switch (event) {
-			case NETDEV_UP:
-				x25_link_device_up(dev);
-				break;
-			case NETDEV_GOING_DOWN:
-				nb = x25_get_neigh(dev);
-				if (nb) {
-					x25_terminate_link(nb);
-					x25_neigh_put(nb);
-				}
-				break;
-			case NETDEV_DOWN:
-				x25_kill_by_device(dev);
-				x25_route_device_down(dev);
-				x25_link_device_down(dev);
-				break;
+		case NETDEV_UP:
+			x25_link_device_up(dev);
+			break;
+		case NETDEV_GOING_DOWN:
+			nb = x25_get_neigh(dev);
+			if (nb) {
+				x25_terminate_link(nb);
+				x25_neigh_put(nb);
+			}
+			break;
+		case NETDEV_DOWN:
+			x25_kill_by_device(dev);
+			x25_route_device_down(dev);
+			x25_link_device_down(dev);
+			break;
 		}
 	}
 
@@ -1336,256 +1336,253 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	int rc;
 
 	switch (cmd) {
-		case TIOCOUTQ: {
-			int amount;
+	case TIOCOUTQ: {
+		int amount;
 
-			amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
-			if (amount < 0)
-				amount = 0;
-			rc = put_user(amount, (unsigned int __user *)argp);
-			break;
-		}
+		amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
+		if (amount < 0)
+			amount = 0;
+		rc = put_user(amount, (unsigned int __user *)argp);
+		break;
+	}
 
-		case TIOCINQ: {
-			struct sk_buff *skb;
-			int amount = 0;
-			/*
-			 * These two are safe on a single CPU system as
-			 * only user tasks fiddle here
-			 */
-			lock_sock(sk);
-			if ((skb = skb_peek(&sk->sk_receive_queue)) != NULL)
-				amount = skb->len;
-			release_sock(sk);
-			rc = put_user(amount, (unsigned int __user *)argp);
-			break;
-		}
+	case TIOCINQ: {
+		struct sk_buff *skb;
+		int amount = 0;
+		/*
+		 * These two are safe on a single CPU system as
+		 * only user tasks fiddle here
+		 */
+		lock_sock(sk);
+		if ((skb = skb_peek(&sk->sk_receive_queue)) != NULL)
+			amount = skb->len;
+		release_sock(sk);
+		rc = put_user(amount, (unsigned int __user *)argp);
+		break;
+	}
 
-		case SIOCGSTAMP:
-			rc = -EINVAL;
-			if (sk)
-				rc = sock_get_timestamp(sk,
+	case SIOCGSTAMP:
+		rc = -EINVAL;
+		if (sk)
+			rc = sock_get_timestamp(sk,
 						(struct timeval __user *)argp);
+		break;
+	case SIOCGSTAMPNS:
+		rc = -EINVAL;
+		if (sk)
+			rc = sock_get_timestampns(sk,
+					(struct timespec __user *)argp);
+		break;
+	case SIOCGIFADDR:
+	case SIOCSIFADDR:
+	case SIOCGIFDSTADDR:
+	case SIOCSIFDSTADDR:
+	case SIOCGIFBRDADDR:
+	case SIOCSIFBRDADDR:
+	case SIOCGIFNETMASK:
+	case SIOCSIFNETMASK:
+	case SIOCGIFMETRIC:
+	case SIOCSIFMETRIC:
+		rc = -EINVAL;
+		break;
+	case SIOCADDRT:
+	case SIOCDELRT:
+		rc = -EPERM;
+		if (!capable(CAP_NET_ADMIN))
 			break;
-		case SIOCGSTAMPNS:
-			rc = -EINVAL;
-			if (sk)
-				rc = sock_get_timestampns(sk,
-						(struct timespec __user *)argp);
-			break;
-		case SIOCGIFADDR:
-		case SIOCSIFADDR:
-		case SIOCGIFDSTADDR:
-		case SIOCSIFDSTADDR:
-		case SIOCGIFBRDADDR:
-		case SIOCSIFBRDADDR:
-		case SIOCGIFNETMASK:
-		case SIOCSIFNETMASK:
-		case SIOCGIFMETRIC:
-		case SIOCSIFMETRIC:
-			rc = -EINVAL;
-			break;
-		case SIOCADDRT:
-		case SIOCDELRT:
-			rc = -EPERM;
-			if (!capable(CAP_NET_ADMIN))
-				break;
-			rc = x25_route_ioctl(cmd, argp);
-			break;
-		case SIOCX25GSUBSCRIP:
-			rc = x25_subscr_ioctl(cmd, argp);
-			break;
-		case SIOCX25SSUBSCRIP:
-			rc = -EPERM;
-			if (!capable(CAP_NET_ADMIN))
-				break;
-			rc = x25_subscr_ioctl(cmd, argp);
-			break;
-		case SIOCX25GFACILITIES: {
-			lock_sock(sk);
-			rc = copy_to_user(argp, &x25->facilities,
-						sizeof(x25->facilities))
-						? -EFAULT : 0;
-			release_sock(sk);
+		rc = x25_route_ioctl(cmd, argp);
+		break;
+	case SIOCX25GSUBSCRIP:
+		rc = x25_subscr_ioctl(cmd, argp);
+		break;
+	case SIOCX25SSUBSCRIP:
+		rc = -EPERM;
+		if (!capable(CAP_NET_ADMIN))
 			break;
-		}
+		rc = x25_subscr_ioctl(cmd, argp);
+		break;
+	case SIOCX25GFACILITIES: {
+		lock_sock(sk);
+		rc = copy_to_user(argp, &x25->facilities,
+				  sizeof(x25->facilities))
+			? -EFAULT : 0;
+		release_sock(sk);
+		break;
+	}
 
-		case SIOCX25SFACILITIES: {
-			struct x25_facilities facilities;
-			rc = -EFAULT;
-			if (copy_from_user(&facilities, argp,
-					   sizeof(facilities)))
-				break;
-			rc = -EINVAL;
-			lock_sock(sk);
-			if (sk->sk_state != TCP_LISTEN &&
-			    sk->sk_state != TCP_CLOSE)
-				goto out_fac_release;
-			if (facilities.pacsize_in < X25_PS16 ||
-			    facilities.pacsize_in > X25_PS4096)
-				goto out_fac_release;
-			if (facilities.pacsize_out < X25_PS16 ||
-			    facilities.pacsize_out > X25_PS4096)
-				goto out_fac_release;
-			if (facilities.winsize_in < 1 ||
-			    facilities.winsize_in > 127)
+	case SIOCX25SFACILITIES: {
+		struct x25_facilities facilities;
+		rc = -EFAULT;
+		if (copy_from_user(&facilities, argp, sizeof(facilities)))
+			break;
+		rc = -EINVAL;
+		lock_sock(sk);
+		if (sk->sk_state != TCP_LISTEN &&
+		    sk->sk_state != TCP_CLOSE)
+			goto out_fac_release;
+		if (facilities.pacsize_in < X25_PS16 ||
+		    facilities.pacsize_in > X25_PS4096)
+			goto out_fac_release;
+		if (facilities.pacsize_out < X25_PS16 ||
+		    facilities.pacsize_out > X25_PS4096)
+			goto out_fac_release;
+		if (facilities.winsize_in < 1 ||
+		    facilities.winsize_in > 127)
+			goto out_fac_release;
+		if (facilities.throughput) {
+			int out = facilities.throughput & 0xf0;
+			int in  = facilities.throughput & 0x0f;
+			if (!out)
+				facilities.throughput |=
+					X25_DEFAULT_THROUGHPUT << 4;
+			else if (out < 0x30 || out > 0xD0)
 				goto out_fac_release;
-			if (facilities.throughput) {
-				int out = facilities.throughput & 0xf0;
-				int in  = facilities.throughput & 0x0f;
-				if (!out)
-					facilities.throughput |=
-						X25_DEFAULT_THROUGHPUT << 4;
-				else if (out < 0x30 || out > 0xD0)
-					goto out_fac_release;
-				if (!in)
-					facilities.throughput |=
-						X25_DEFAULT_THROUGHPUT;
-				else if (in < 0x03 || in > 0x0D)
-					goto out_fac_release;
-			}
-			if (facilities.reverse &&
-				(facilities.reverse & 0x81) != 0x81)
+			if (!in)
+				facilities.throughput |=
+					X25_DEFAULT_THROUGHPUT;
+			else if (in < 0x03 || in > 0x0D)
 				goto out_fac_release;
-			x25->facilities = facilities;
-			rc = 0;
-out_fac_release:
-			release_sock(sk);
-			break;
-		}
-
-		case SIOCX25GDTEFACILITIES: {
-			lock_sock(sk);
-			rc = copy_to_user(argp, &x25->dte_facilities,
-						sizeof(x25->dte_facilities));
-			release_sock(sk);
-			if (rc)
-				rc = -EFAULT;
-			break;
 		}
+		if (facilities.reverse &&
+		    (facilities.reverse & 0x81) != 0x81)
+			goto out_fac_release;
+		x25->facilities = facilities;
+		rc = 0;
+out_fac_release:
+		release_sock(sk);
+		break;
+	}
 
-		case SIOCX25SDTEFACILITIES: {
-			struct x25_dte_facilities dtefacs;
+	case SIOCX25GDTEFACILITIES: {
+		lock_sock(sk);
+		rc = copy_to_user(argp, &x25->dte_facilities,
+				  sizeof(x25->dte_facilities));
+		release_sock(sk);
+		if (rc)
 			rc = -EFAULT;
-			if (copy_from_user(&dtefacs, argp, sizeof(dtefacs)))
-				break;
-			rc = -EINVAL;
-			lock_sock(sk);
-			if (sk->sk_state != TCP_LISTEN &&
-					sk->sk_state != TCP_CLOSE)
-				goto out_dtefac_release;
-			if (dtefacs.calling_len > X25_MAX_AE_LEN)
-				goto out_dtefac_release;
-			if (dtefacs.calling_ae == NULL)
-				goto out_dtefac_release;
-			if (dtefacs.called_len > X25_MAX_AE_LEN)
-				goto out_dtefac_release;
-			if (dtefacs.called_ae == NULL)
-				goto out_dtefac_release;
-			x25->dte_facilities = dtefacs;
-			rc = 0;
-out_dtefac_release:
-			release_sock(sk);
-			break;
-		}
+		break;
+	}
 
-		case SIOCX25GCALLUSERDATA: {
-			lock_sock(sk);
-			rc = copy_to_user(argp, &x25->calluserdata,
-					sizeof(x25->calluserdata))
-					? -EFAULT : 0;
-			release_sock(sk);
+	case SIOCX25SDTEFACILITIES: {
+		struct x25_dte_facilities dtefacs;
+		rc = -EFAULT;
+		if (copy_from_user(&dtefacs, argp, sizeof(dtefacs)))
 			break;
-		}
+		rc = -EINVAL;
+		lock_sock(sk);
+		if (sk->sk_state != TCP_LISTEN &&
+		    sk->sk_state != TCP_CLOSE)
+			goto out_dtefac_release;
+		if (dtefacs.calling_len > X25_MAX_AE_LEN)
+			goto out_dtefac_release;
+		if (dtefacs.calling_ae == NULL)
+			goto out_dtefac_release;
+		if (dtefacs.called_len > X25_MAX_AE_LEN)
+			goto out_dtefac_release;
+		if (dtefacs.called_ae == NULL)
+			goto out_dtefac_release;
+		x25->dte_facilities = dtefacs;
+		rc = 0;
+out_dtefac_release:
+		release_sock(sk);
+		break;
+	}
 
-		case SIOCX25SCALLUSERDATA: {
-			struct x25_calluserdata calluserdata;
+	case SIOCX25GCALLUSERDATA: {
+		lock_sock(sk);
+		rc = copy_to_user(argp, &x25->calluserdata,
+				  sizeof(x25->calluserdata))
+			? -EFAULT : 0;
+		release_sock(sk);
+		break;
+	}
 
-			rc = -EFAULT;
-			if (copy_from_user(&calluserdata, argp,
-					   sizeof(calluserdata)))
-				break;
-			rc = -EINVAL;
-			if (calluserdata.cudlength > X25_MAX_CUD_LEN)
-				break;
-			lock_sock(sk);
-			x25->calluserdata = calluserdata;
-			release_sock(sk);
-			rc = 0;
-			break;
-		}
+	case SIOCX25SCALLUSERDATA: {
+		struct x25_calluserdata calluserdata;
 
-		case SIOCX25GCAUSEDIAG: {
-			lock_sock(sk);
-			rc = copy_to_user(argp, &x25->causediag,
-					sizeof(x25->causediag))
-					? -EFAULT : 0;
-			release_sock(sk);
+		rc = -EFAULT;
+		if (copy_from_user(&calluserdata, argp, sizeof(calluserdata)))
 			break;
-		}
+		rc = -EINVAL;
+		if (calluserdata.cudlength > X25_MAX_CUD_LEN)
+			break;
+		lock_sock(sk);
+		x25->calluserdata = calluserdata;
+		release_sock(sk);
+		rc = 0;
+		break;
+	}
 
-		case SIOCX25SCAUSEDIAG: {
-			struct x25_causediag causediag;
-			rc = -EFAULT;
-			if (copy_from_user(&causediag, argp, sizeof(causediag)))
-				break;
-			lock_sock(sk);
-			x25->causediag = causediag;
-			release_sock(sk);
-			rc = 0;
+	case SIOCX25GCAUSEDIAG: {
+		lock_sock(sk);
+		rc = copy_to_user(argp, &x25->causediag, sizeof(x25->causediag))
+			? -EFAULT : 0;
+		release_sock(sk);
+		break;
+	}
+
+	case SIOCX25SCAUSEDIAG: {
+		struct x25_causediag causediag;
+		rc = -EFAULT;
+		if (copy_from_user(&causediag, argp, sizeof(causediag)))
 			break;
+		lock_sock(sk);
+		x25->causediag = causediag;
+		release_sock(sk);
+		rc = 0;
+		break;
 
-		}
+	}
 
-		case SIOCX25SCUDMATCHLEN: {
-			struct x25_subaddr sub_addr;
-			rc = -EINVAL;
-			lock_sock(sk);
-			if(sk->sk_state != TCP_CLOSE)
-				goto out_cud_release;
-			rc = -EFAULT;
-			if (copy_from_user(&sub_addr, argp,
-					sizeof(sub_addr)))
-				goto out_cud_release;
-			rc = -EINVAL;
-			if(sub_addr.cudmatchlength > X25_MAX_CUD_LEN)
-				goto out_cud_release;
-			x25->cudmatchlength = sub_addr.cudmatchlength;
-			rc = 0;
+	case SIOCX25SCUDMATCHLEN: {
+		struct x25_subaddr sub_addr;
+		rc = -EINVAL;
+		lock_sock(sk);
+		if(sk->sk_state != TCP_CLOSE)
+			goto out_cud_release;
+		rc = -EFAULT;
+		if (copy_from_user(&sub_addr, argp,
+				   sizeof(sub_addr)))
+			goto out_cud_release;
+		rc = -EINVAL;
+		if (sub_addr.cudmatchlength > X25_MAX_CUD_LEN)
+			goto out_cud_release;
+		x25->cudmatchlength = sub_addr.cudmatchlength;
+		rc = 0;
 out_cud_release:
-			release_sock(sk);
-			break;
-		}
+		release_sock(sk);
+		break;
+	}
 
-		case SIOCX25CALLACCPTAPPRV: {
-			rc = -EINVAL;
-			lock_sock(sk);
-			if (sk->sk_state != TCP_CLOSE)
-				break;
-			clear_bit(X25_ACCPT_APPRV_FLAG, &x25->flags);
-			release_sock(sk);
-			rc = 0;
+	case SIOCX25CALLACCPTAPPRV: {
+		rc = -EINVAL;
+		lock_sock(sk);
+		if (sk->sk_state != TCP_CLOSE)
 			break;
-		}
+		clear_bit(X25_ACCPT_APPRV_FLAG, &x25->flags);
+		release_sock(sk);
+		rc = 0;
+		break;
+	}
 
-		case SIOCX25SENDCALLACCPT:  {
-			rc = -EINVAL;
-			lock_sock(sk);
-			if (sk->sk_state != TCP_ESTABLISHED)
-				break;
-			/* must call accptapprv above */
-			if (test_bit(X25_ACCPT_APPRV_FLAG, &x25->flags))
-				break;
-			x25_write_internal(sk, X25_CALL_ACCEPTED);
-			x25->state = X25_STATE_3;
-			release_sock(sk);
-			rc = 0;
+	case SIOCX25SENDCALLACCPT:  {
+		rc = -EINVAL;
+		lock_sock(sk);
+		if (sk->sk_state != TCP_ESTABLISHED)
 			break;
-		}
-
-		default:
-			rc = -ENOIOCTLCMD;
+		/* must call accptapprv above */
+		if (test_bit(X25_ACCPT_APPRV_FLAG, &x25->flags))
 			break;
+		x25_write_internal(sk, X25_CALL_ACCEPTED);
+		x25->state = X25_STATE_3;
+		release_sock(sk);
+		rc = 0;
+		break;
+	}
+
+	default:
+		rc = -ENOIOCTLCMD;
+		break;
 	}
 
 	return rc;
diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
index 9005f6d..e547ca1 100644
--- a/net/x25/x25_dev.c
+++ b/net/x25/x25_dev.c
@@ -146,21 +146,21 @@ void x25_establish_link(struct x25_neigh *nb)
 	unsigned char *ptr;
 
 	switch (nb->dev->type) {
-		case ARPHRD_X25:
-			if ((skb = alloc_skb(1, GFP_ATOMIC)) == NULL) {
-				printk(KERN_ERR "x25_dev: out of memory\n");
-				return;
-			}
-			ptr  = skb_put(skb, 1);
-			*ptr = X25_IFACE_CONNECT;
-			break;
+	case ARPHRD_X25:
+		if ((skb = alloc_skb(1, GFP_ATOMIC)) == NULL) {
+			printk(KERN_ERR "x25_dev: out of memory\n");
+			return;
+		}
+		ptr  = skb_put(skb, 1);
+		*ptr = X25_IFACE_CONNECT;
+		break;
 
 #if defined(CONFIG_LLC) || defined(CONFIG_LLC_MODULE)
-		case ARPHRD_ETHER:
-			return;
+	case ARPHRD_ETHER:
+		return;
 #endif
-		default:
-			return;
+	default:
+		return;
 	}
 
 	skb->protocol = htons(ETH_P_X25);
@@ -202,19 +202,19 @@ void x25_send_frame(struct sk_buff *skb, struct x25_neigh *nb)
 	skb_reset_network_header(skb);
 
 	switch (nb->dev->type) {
-		case ARPHRD_X25:
-			dptr  = skb_push(skb, 1);
-			*dptr = X25_IFACE_DATA;
-			break;
+	case ARPHRD_X25:
+		dptr  = skb_push(skb, 1);
+		*dptr = X25_IFACE_DATA;
+		break;
 
 #if defined(CONFIG_LLC) || defined(CONFIG_LLC_MODULE)
-		case ARPHRD_ETHER:
-			kfree_skb(skb);
-			return;
+	case ARPHRD_ETHER:
+		kfree_skb(skb);
+		return;
 #endif
-		default:
-			kfree_skb(skb);
-			return;
+	default:
+		kfree_skb(skb);
+		return;
 	}
 
 	skb->protocol = htons(ETH_P_X25);
diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
index 15de65f..0b073b5 100644
--- a/net/x25/x25_in.c
+++ b/net/x25/x25_in.c
@@ -94,55 +94,55 @@ static int x25_state1_machine(struct sock *sk, struct sk_buff *skb, int frametyp
 	struct x25_sock *x25 = x25_sk(sk);
 
 	switch (frametype) {
-		case X25_CALL_ACCEPTED: {
-
-			x25_stop_timer(sk);
-			x25->condition = 0x00;
-			x25->vs        = 0;
-			x25->va        = 0;
-			x25->vr        = 0;
-			x25->vl        = 0;
-			x25->state     = X25_STATE_3;
-			sk->sk_state   = TCP_ESTABLISHED;
-			/*
-			 *	Parse the data in the frame.
-			 */
-			skb_pull(skb, X25_STD_MIN_LEN);
-
-			len = x25_parse_address_block(skb, &source_addr,
-						&dest_addr);
-			if (len > 0)
-				skb_pull(skb, len);
-			else if (len < 0)
-				goto out_clear;
-
-			len = x25_parse_facilities(skb, &x25->facilities,
-						&x25->dte_facilities,
-						&x25->vc_facil_mask);
-			if (len > 0)
-				skb_pull(skb, len);
-			else if (len < 0)
-				goto out_clear;
-			/*
-			 *	Copy any Call User Data.
-			 */
-			if (skb->len > 0) {
-				skb_copy_from_linear_data(skb,
-					      x25->calluserdata.cuddata,
-					      skb->len);
-				x25->calluserdata.cudlength = skb->len;
-			}
-			if (!sock_flag(sk, SOCK_DEAD))
-				sk->sk_state_change(sk);
-			break;
+	case X25_CALL_ACCEPTED: {
+
+		x25_stop_timer(sk);
+		x25->condition = 0x00;
+		x25->vs        = 0;
+		x25->va        = 0;
+		x25->vr        = 0;
+		x25->vl        = 0;
+		x25->state     = X25_STATE_3;
+		sk->sk_state   = TCP_ESTABLISHED;
+		/*
+		 *	Parse the data in the frame.
+		 */
+		skb_pull(skb, X25_STD_MIN_LEN);
+
+		len = x25_parse_address_block(skb, &source_addr,
+					      &dest_addr);
+		if (len > 0)
+			skb_pull(skb, len);
+		else if (len < 0)
+			goto out_clear;
+
+		len = x25_parse_facilities(skb, &x25->facilities,
+					   &x25->dte_facilities,
+					   &x25->vc_facil_mask);
+		if (len > 0)
+			skb_pull(skb, len);
+		else if (len < 0)
+			goto out_clear;
+		/*
+		 *	Copy any Call User Data.
+		 */
+		if (skb->len > 0) {
+			skb_copy_from_linear_data(skb,
+						  x25->calluserdata.cuddata,
+						  skb->len);
+			x25->calluserdata.cudlength = skb->len;
 		}
-		case X25_CLEAR_REQUEST:
-			x25_write_internal(sk, X25_CLEAR_CONFIRMATION);
-			x25_disconnect(sk, ECONNREFUSED, skb->data[3], skb->data[4]);
-			break;
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_state_change(sk);
+		break;
+	}
+	case X25_CLEAR_REQUEST:
+		x25_write_internal(sk, X25_CLEAR_CONFIRMATION);
+		x25_disconnect(sk, ECONNREFUSED, skb->data[3], skb->data[4]);
+		break;
 
-		default:
-			break;
+	default:
+		break;
 	}
 
 	return 0;
@@ -354,18 +354,18 @@ int x25_process_rx_frame(struct sock *sk, struct sk_buff *skb)
 	frametype = x25_decode(sk, skb, &ns, &nr, &q, &d, &m);
 
 	switch (x25->state) {
-		case X25_STATE_1:
-			queued = x25_state1_machine(sk, skb, frametype);
-			break;
-		case X25_STATE_2:
-			queued = x25_state2_machine(sk, skb, frametype);
-			break;
-		case X25_STATE_3:
-			queued = x25_state3_machine(sk, skb, frametype, ns, nr, q, d, m);
-			break;
-		case X25_STATE_4:
-			queued = x25_state4_machine(sk, skb, frametype);
-			break;
+	case X25_STATE_1:
+		queued = x25_state1_machine(sk, skb, frametype);
+		break;
+	case X25_STATE_2:
+		queued = x25_state2_machine(sk, skb, frametype);
+		break;
+	case X25_STATE_3:
+		queued = x25_state3_machine(sk, skb, frametype, ns, nr, q, d, m);
+		break;
+	case X25_STATE_4:
+		queued = x25_state4_machine(sk, skb, frametype);
+		break;
 	}
 
 	x25_kick(sk);
diff --git a/net/x25/x25_link.c b/net/x25/x25_link.c
index 2130692..037958f 100644
--- a/net/x25/x25_link.c
+++ b/net/x25/x25_link.c
@@ -76,30 +76,29 @@ void x25_link_control(struct sk_buff *skb, struct x25_neigh *nb,
 	int confirm;
 
 	switch (frametype) {
-		case X25_RESTART_REQUEST:
-			confirm = !x25_t20timer_pending(nb);
-			x25_stop_t20timer(nb);
-			nb->state = X25_LINK_STATE_3;
-			if (confirm)
-				x25_transmit_restart_confirmation(nb);
-			break;
-
-		case X25_RESTART_CONFIRMATION:
-			x25_stop_t20timer(nb);
-			nb->state = X25_LINK_STATE_3;
-			break;
-
-		case X25_DIAGNOSTIC:
-			printk(KERN_WARNING "x25: diagnostic #%d - "
-			       "%02X %02X %02X\n",
-			       skb->data[3], skb->data[4],
-			       skb->data[5], skb->data[6]);
-			break;
-
-		default:
-			printk(KERN_WARNING "x25: received unknown %02X "
-			       "with LCI 000\n", frametype);
-			break;
+	case X25_RESTART_REQUEST:
+		confirm = !x25_t20timer_pending(nb);
+		x25_stop_t20timer(nb);
+		nb->state = X25_LINK_STATE_3;
+		if (confirm)
+			x25_transmit_restart_confirmation(nb);
+		break;
+
+	case X25_RESTART_CONFIRMATION:
+		x25_stop_t20timer(nb);
+		nb->state = X25_LINK_STATE_3;
+		break;
+
+	case X25_DIAGNOSTIC:
+		printk(KERN_WARNING "x25: diagnostic #%d - %02X %02X %02X\n",
+		       skb->data[3], skb->data[4],
+		       skb->data[5], skb->data[6]);
+		break;
+
+	default:
+		printk(KERN_WARNING "x25: received unknown %02X with LCI 000\n",
+		       frametype);
+		break;
 	}
 
 	if (nb->state == X25_LINK_STATE_3)
@@ -193,18 +192,18 @@ void x25_transmit_clear_request(struct x25_neigh *nb, unsigned int lci,
 void x25_transmit_link(struct sk_buff *skb, struct x25_neigh *nb)
 {
 	switch (nb->state) {
-		case X25_LINK_STATE_0:
-			skb_queue_tail(&nb->queue, skb);
-			nb->state = X25_LINK_STATE_1;
-			x25_establish_link(nb);
-			break;
-		case X25_LINK_STATE_1:
-		case X25_LINK_STATE_2:
-			skb_queue_tail(&nb->queue, skb);
-			break;
-		case X25_LINK_STATE_3:
-			x25_send_frame(skb, nb);
-			break;
+	case X25_LINK_STATE_0:
+		skb_queue_tail(&nb->queue, skb);
+		nb->state = X25_LINK_STATE_1;
+		x25_establish_link(nb);
+		break;
+	case X25_LINK_STATE_1:
+	case X25_LINK_STATE_2:
+		skb_queue_tail(&nb->queue, skb);
+		break;
+	case X25_LINK_STATE_3:
+		x25_send_frame(skb, nb);
+		break;
 	}
 }
 
@@ -214,14 +213,14 @@ void x25_transmit_link(struct sk_buff *skb, struct x25_neigh *nb)
 void x25_link_established(struct x25_neigh *nb)
 {
 	switch (nb->state) {
-		case X25_LINK_STATE_0:
-			nb->state = X25_LINK_STATE_2;
-			break;
-		case X25_LINK_STATE_1:
-			x25_transmit_restart_request(nb);
-			nb->state = X25_LINK_STATE_2;
-			x25_start_t20timer(nb);
-			break;
+	case X25_LINK_STATE_0:
+		nb->state = X25_LINK_STATE_2;
+		break;
+	case X25_LINK_STATE_1:
+		x25_transmit_restart_request(nb);
+		nb->state = X25_LINK_STATE_2;
+		x25_start_t20timer(nb);
+		break;
 	}
 }
 
diff --git a/net/x25/x25_subr.c b/net/x25/x25_subr.c
index dc20cf1..24a342e 100644
--- a/net/x25/x25_subr.c
+++ b/net/x25/x25_subr.c
@@ -126,32 +126,30 @@ void x25_write_internal(struct sock *sk, int frametype)
 	 *	Adjust frame size.
 	 */
 	switch (frametype) {
-		case X25_CALL_REQUEST:
-			len += 1 + X25_ADDR_LEN + X25_MAX_FAC_LEN +
-			       X25_MAX_CUD_LEN;
-			break;
-		case X25_CALL_ACCEPTED: /* fast sel with no restr on resp */
-			if(x25->facilities.reverse & 0x80) {
-				len += 1 + X25_MAX_FAC_LEN + X25_MAX_CUD_LEN;
-			} else {
-				len += 1 + X25_MAX_FAC_LEN;
-			}
-			break;
-		case X25_CLEAR_REQUEST:
-		case X25_RESET_REQUEST:
-			len += 2;
-			break;
-		case X25_RR:
-		case X25_RNR:
-		case X25_REJ:
-		case X25_CLEAR_CONFIRMATION:
-		case X25_INTERRUPT_CONFIRMATION:
-		case X25_RESET_CONFIRMATION:
-			break;
-		default:
-			printk(KERN_ERR "X.25: invalid frame type %02X\n",
-			       frametype);
-			return;
+	case X25_CALL_REQUEST:
+		len += 1 + X25_ADDR_LEN + X25_MAX_FAC_LEN + X25_MAX_CUD_LEN;
+		break;
+	case X25_CALL_ACCEPTED: /* fast sel with no restr on resp */
+		if (x25->facilities.reverse & 0x80) {
+			len += 1 + X25_MAX_FAC_LEN + X25_MAX_CUD_LEN;
+		} else {
+			len += 1 + X25_MAX_FAC_LEN;
+		}
+		break;
+	case X25_CLEAR_REQUEST:
+	case X25_RESET_REQUEST:
+		len += 2;
+		break;
+	case X25_RR:
+	case X25_RNR:
+	case X25_REJ:
+	case X25_CLEAR_CONFIRMATION:
+	case X25_INTERRUPT_CONFIRMATION:
+	case X25_RESET_CONFIRMATION:
+		break;
+	default:
+		printk(KERN_ERR "X.25: invalid frame type %02X\n", frametype);
+		return;
 	}
 
 	if ((skb = alloc_skb(len, GFP_ATOMIC)) == NULL)
@@ -276,20 +274,20 @@ int x25_decode(struct sock *sk, struct sk_buff *skb, int *ns, int *nr, int *q,
 	*ns = *nr = *q = *d = *m = 0;
 
 	switch (frame[2]) {
-		case X25_CALL_REQUEST:
-		case X25_CALL_ACCEPTED:
-		case X25_CLEAR_REQUEST:
-		case X25_CLEAR_CONFIRMATION:
-		case X25_INTERRUPT:
-		case X25_INTERRUPT_CONFIRMATION:
-		case X25_RESET_REQUEST:
-		case X25_RESET_CONFIRMATION:
-		case X25_RESTART_REQUEST:
-		case X25_RESTART_CONFIRMATION:
-		case X25_REGISTRATION_REQUEST:
-		case X25_REGISTRATION_CONFIRMATION:
-		case X25_DIAGNOSTIC:
-			return frame[2];
+	case X25_CALL_REQUEST:
+	case X25_CALL_ACCEPTED:
+	case X25_CLEAR_REQUEST:
+	case X25_CLEAR_CONFIRMATION:
+	case X25_INTERRUPT:
+	case X25_INTERRUPT_CONFIRMATION:
+	case X25_RESET_REQUEST:
+	case X25_RESET_CONFIRMATION:
+	case X25_RESTART_REQUEST:
+	case X25_RESTART_CONFIRMATION:
+	case X25_REGISTRATION_REQUEST:
+	case X25_REGISTRATION_CONFIRMATION:
+	case X25_DIAGNOSTIC:
+		return frame[2];
 	}
 
 	if (x25->neighbour->extended) {
-- 
1.7.6.rc1

