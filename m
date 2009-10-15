From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] sctp: remove deprecated SCTP_GET_*_OLD stuffs
Date: Thu, 15 Oct 2009 04:26:08 -0400
Message-ID: <20091015082849.4605.48311.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Amerigo Wang <amwang@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762437AbZJOI0p@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


SCTP_GET_*_OLD stuffs are schedlued to be removed.

Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: WANG Cong <amwang@redhat.com>


---
diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 04e6c81..0b0eee5 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -302,18 +302,6 @@ Who:	ocfs2-devel@oss.oracle.com
 
 ---------------------------
 
-What:	SCTP_GET_PEER_ADDRS_NUM_OLD, SCTP_GET_PEER_ADDRS_OLD,
-	SCTP_GET_LOCAL_ADDRS_NUM_OLD, SCTP_GET_LOCAL_ADDRS_OLD
-When: 	June 2009
-Why:    A newer version of the options have been introduced in 2005 that
-	removes the limitions of the old API.  The sctp library has been
-        converted to use these new options at the same time.  Any user
-	space app that directly uses the old options should convert to using
-	the new options.
-Who:	Vlad Yasevich <vladislav.yasevich@hp.com>
-
----------------------------
-
 What:	Ability for non root users to shm_get hugetlb pages based on mlock
 	resource limits
 When:	2.6.31
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index be2334a..0991f1b 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -131,14 +131,6 @@ enum sctp_optname {
 #define SCTP_SOCKOPT_BINDX_REM	SCTP_SOCKOPT_BINDX_REM
 	SCTP_SOCKOPT_PEELOFF, 	/* peel off association. */
 #define SCTP_SOCKOPT_PEELOFF	SCTP_SOCKOPT_PEELOFF
-	SCTP_GET_PEER_ADDRS_NUM_OLD, 	/* Get number of peer addresss. */
-#define SCTP_GET_PEER_ADDRS_NUM_OLD	SCTP_GET_PEER_ADDRS_NUM_OLD
-	SCTP_GET_PEER_ADDRS_OLD, 	/* Get all peer addresss. */
-#define SCTP_GET_PEER_ADDRS_OLD	SCTP_GET_PEER_ADDRS_OLD
-	SCTP_GET_LOCAL_ADDRS_NUM_OLD, 	/* Get number of local addresss. */
-#define SCTP_GET_LOCAL_ADDRS_NUM_OLD	SCTP_GET_LOCAL_ADDRS_NUM_OLD
-	SCTP_GET_LOCAL_ADDRS_OLD, 	/* Get all local addresss. */
-#define SCTP_GET_LOCAL_ADDRS_OLD	SCTP_GET_LOCAL_ADDRS_OLD
 	SCTP_SOCKOPT_CONNECTX_OLD, /* CONNECTX old requests. */
 #define SCTP_SOCKOPT_CONNECTX_OLD	SCTP_SOCKOPT_CONNECTX_OLD
 	SCTP_GET_PEER_ADDRS, 	/* Get all peer addresss. */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index c8d0575..1732a70 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4339,90 +4339,6 @@ static int sctp_getsockopt_initmsg(struct sock *sk, int len, char __user *optval
 	return 0;
 }
 
-static int sctp_getsockopt_peer_addrs_num_old(struct sock *sk, int len,
-					      char __user *optval,
-					      int __user *optlen)
-{
-	sctp_assoc_t id;
-	struct sctp_association *asoc;
-	struct list_head *pos;
-	int cnt = 0;
-
-	if (len < sizeof(sctp_assoc_t))
-		return -EINVAL;
-
-	if (copy_from_user(&id, optval, sizeof(sctp_assoc_t)))
-		return -EFAULT;
-
-	printk(KERN_WARNING "SCTP: Use of SCTP_GET_PEER_ADDRS_NUM_OLD "
-			    "socket option deprecated\n");
-	/* For UDP-style sockets, id specifies the association to query.  */
-	asoc = sctp_id2assoc(sk, id);
-	if (!asoc)
-		return -EINVAL;
-
-	list_for_each(pos, &asoc->peer.transport_addr_list) {
-		cnt ++;
-	}
-
-	return cnt;
-}
-
-/*
- * Old API for getting list of peer addresses. Does not work for 32-bit
- * programs running on a 64-bit kernel
- */
-static int sctp_getsockopt_peer_addrs_old(struct sock *sk, int len,
-					  char __user *optval,
-					  int __user *optlen)
-{
-	struct sctp_association *asoc;
-	int cnt = 0;
-	struct sctp_getaddrs_old getaddrs;
-	struct sctp_transport *from;
-	void __user *to;
-	union sctp_addr temp;
-	struct sctp_sock *sp = sctp_sk(sk);
-	int addrlen;
-
-	if (len < sizeof(struct sctp_getaddrs_old))
-		return -EINVAL;
-
-	len = sizeof(struct sctp_getaddrs_old);
-
-	if (copy_from_user(&getaddrs, optval, len))
-		return -EFAULT;
-
-	if (getaddrs.addr_num <= 0) return -EINVAL;
-
-	printk(KERN_WARNING "SCTP: Use of SCTP_GET_PEER_ADDRS_OLD "
-			    "socket option deprecated\n");
-
-	/* For UDP-style sockets, id specifies the association to query.  */
-	asoc = sctp_id2assoc(sk, getaddrs.assoc_id);
-	if (!asoc)
-		return -EINVAL;
-
-	to = (void __user *)getaddrs.addrs;
-	list_for_each_entry(from, &asoc->peer.transport_addr_list,
-				transports) {
-		memcpy(&temp, &from->ipaddr, sizeof(temp));
-		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sp, &temp);
-		addrlen = sctp_get_af_specific(sk->sk_family)->sockaddr_len;
-		if (copy_to_user(to, &temp, addrlen))
-			return -EFAULT;
-		to += addrlen ;
-		cnt ++;
-		if (cnt >= getaddrs.addr_num) break;
-	}
-	getaddrs.addr_num = cnt;
-	if (put_user(len, optlen))
-		return -EFAULT;
-	if (copy_to_user(optval, &getaddrs, len))
-		return -EFAULT;
-
-	return 0;
-}
 
 static int sctp_getsockopt_peer_addrs(struct sock *sk, int len,
 				      char __user *optval, int __user *optlen)
@@ -4475,81 +4391,6 @@ static int sctp_getsockopt_peer_addrs(struct sock *sk, int len,
 	return 0;
 }
 
-static int sctp_getsockopt_local_addrs_num_old(struct sock *sk, int len,
-					       char __user *optval,
-					       int __user *optlen)
-{
-	sctp_assoc_t id;
-	struct sctp_bind_addr *bp;
-	struct sctp_association *asoc;
-	struct sctp_sockaddr_entry *addr;
-	int cnt = 0;
-
-	if (len < sizeof(sctp_assoc_t))
-		return -EINVAL;
-
-	if (copy_from_user(&id, optval, sizeof(sctp_assoc_t)))
-		return -EFAULT;
-
-	printk(KERN_WARNING "SCTP: Use of SCTP_GET_LOCAL_ADDRS_NUM_OLD "
-			    "socket option deprecated\n");
-
-	/*
-	 *  For UDP-style sockets, id specifies the association to query.
-	 *  If the id field is set to the value '0' then the locally bound
-	 *  addresses are returned without regard to any particular
-	 *  association.
-	 */
-	if (0 == id) {
-		bp = &sctp_sk(sk)->ep->base.bind_addr;
-	} else {
-		asoc = sctp_id2assoc(sk, id);
-		if (!asoc)
-			return -EINVAL;
-		bp = &asoc->base.bind_addr;
-	}
-
-	/* If the endpoint is bound to 0.0.0.0 or ::0, count the valid
-	 * addresses from the global local address list.
-	 */
-	if (sctp_list_single_entry(&bp->address_list)) {
-		addr = list_entry(bp->address_list.next,
-				  struct sctp_sockaddr_entry, list);
-		if (sctp_is_any(sk, &addr->a)) {
-			rcu_read_lock();
-			list_for_each_entry_rcu(addr,
-						&sctp_local_addr_list, list) {
-				if (!addr->valid)
-					continue;
-
-				if ((PF_INET == sk->sk_family) &&
-				    (AF_INET6 == addr->a.sa.sa_family))
-					continue;
-
-				if ((PF_INET6 == sk->sk_family) &&
-				    inet_v6_ipv6only(sk) &&
-				    (AF_INET == addr->a.sa.sa_family))
-					continue;
-
-				cnt++;
-			}
-			rcu_read_unlock();
-		} else {
-			cnt = 1;
-		}
-		goto done;
-	}
-
-	/* Protection on the bound address list is not needed,
-	 * since in the socket option context we hold the socket lock,
-	 * so there is no way that the bound address list can change.
-	 */
-	list_for_each_entry(addr, &bp->address_list, list) {
-		cnt ++;
-	}
-done:
-	return cnt;
-}
 
 /* Helper function that copies local addresses to user and returns the number
  * of addresses copied.
@@ -4637,112 +4478,6 @@ static int sctp_copy_laddrs(struct sock *sk, __u16 port, void *to,
 	return cnt;
 }
 
-/* Old API for getting list of local addresses. Does not work for 32-bit
- * programs running on a 64-bit kernel
- */
-static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
-					   char __user *optval, int __user *optlen)
-{
-	struct sctp_bind_addr *bp;
-	struct sctp_association *asoc;
-	int cnt = 0;
-	struct sctp_getaddrs_old getaddrs;
-	struct sctp_sockaddr_entry *addr;
-	void __user *to;
-	union sctp_addr temp;
-	struct sctp_sock *sp = sctp_sk(sk);
-	int addrlen;
-	int err = 0;
-	void *addrs;
-	void *buf;
-	int bytes_copied = 0;
-
-	if (len < sizeof(struct sctp_getaddrs_old))
-		return -EINVAL;
-
-	len = sizeof(struct sctp_getaddrs_old);
-	if (copy_from_user(&getaddrs, optval, len))
-		return -EFAULT;
-
-	if (getaddrs.addr_num <= 0 ||
-	    getaddrs.addr_num >= (INT_MAX / sizeof(union sctp_addr)))
-		return -EINVAL;
-
-	printk(KERN_WARNING "SCTP: Use of SCTP_GET_LOCAL_ADDRS_OLD "
-			    "socket option deprecated\n");
-
-	/*
-	 *  For UDP-style sockets, id specifies the association to query.
-	 *  If the id field is set to the value '0' then the locally bound
-	 *  addresses are returned without regard to any particular
-	 *  association.
-	 */
-	if (0 == getaddrs.assoc_id) {
-		bp = &sctp_sk(sk)->ep->base.bind_addr;
-	} else {
-		asoc = sctp_id2assoc(sk, getaddrs.assoc_id);
-		if (!asoc)
-			return -EINVAL;
-		bp = &asoc->base.bind_addr;
-	}
-
-	to = getaddrs.addrs;
-
-	/* Allocate space for a local instance of packed array to hold all
-	 * the data.  We store addresses here first and then put write them
-	 * to the user in one shot.
-	 */
-	addrs = kmalloc(sizeof(union sctp_addr) * getaddrs.addr_num,
-			GFP_KERNEL);
-	if (!addrs)
-		return -ENOMEM;
-
-	/* If the endpoint is bound to 0.0.0.0 or ::0, get the valid
-	 * addresses from the global local address list.
-	 */
-	if (sctp_list_single_entry(&bp->address_list)) {
-		addr = list_entry(bp->address_list.next,
-				  struct sctp_sockaddr_entry, list);
-		if (sctp_is_any(sk, &addr->a)) {
-			cnt = sctp_copy_laddrs_old(sk, bp->port,
-						   getaddrs.addr_num,
-						   addrs, &bytes_copied);
-			goto copy_getaddrs;
-		}
-	}
-
-	buf = addrs;
-	/* Protection on the bound address list is not needed since
-	 * in the socket option context we hold a socket lock and
-	 * thus the bound address list can't change.
-	 */
-	list_for_each_entry(addr, &bp->address_list, list) {
-		memcpy(&temp, &addr->a, sizeof(temp));
-		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sp, &temp);
-		addrlen = sctp_get_af_specific(temp.sa.sa_family)->sockaddr_len;
-		memcpy(buf, &temp, addrlen);
-		buf += addrlen;
-		bytes_copied += addrlen;
-		cnt ++;
-		if (cnt >= getaddrs.addr_num) break;
-	}
-
-copy_getaddrs:
-	/* copy the entire address list into the user provided space */
-	if (copy_to_user(to, addrs, bytes_copied)) {
-		err = -EFAULT;
-		goto error;
-	}
-
-	/* copy the leading structure back to user */
-	getaddrs.addr_num = cnt;
-	if (copy_to_user(optval, &getaddrs, len))
-		err = -EFAULT;
-
-error:
-	kfree(addrs);
-	return err;
-}
 
 static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
 				       char __user *optval, int __user *optlen)
@@ -5593,22 +5328,6 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 	case SCTP_INITMSG:
 		retval = sctp_getsockopt_initmsg(sk, len, optval, optlen);
 		break;
-	case SCTP_GET_PEER_ADDRS_NUM_OLD:
-		retval = sctp_getsockopt_peer_addrs_num_old(sk, len, optval,
-							    optlen);
-		break;
-	case SCTP_GET_LOCAL_ADDRS_NUM_OLD:
-		retval = sctp_getsockopt_local_addrs_num_old(sk, len, optval,
-							     optlen);
-		break;
-	case SCTP_GET_PEER_ADDRS_OLD:
-		retval = sctp_getsockopt_peer_addrs_old(sk, len, optval,
-							optlen);
-		break;
-	case SCTP_GET_LOCAL_ADDRS_OLD:
-		retval = sctp_getsockopt_local_addrs_old(sk, len, optval,
-							 optlen);
-		break;
 	case SCTP_GET_PEER_ADDRS:
 		retval = sctp_getsockopt_peer_addrs(sk, len, optval,
 						    optlen);
