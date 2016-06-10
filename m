From: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH] netlink.7: describe netlink socket options
Date: Fri, 10 Jun 2016 13:28:37 -0700
Message-ID: <1465590517-7182-1-git-send-email-avagin@openvz.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Christophe Ricard <christophe.ricard-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Cc: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Cc: Christophe Ricard <christophe.ricard-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 man7/netlink.7 | 75 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 75 insertions(+)

diff --git a/man7/netlink.7 b/man7/netlink.7
index 513f854..b4848df 100644
--- a/man7/netlink.7
+++ b/man7/netlink.7
@@ -368,6 +368,81 @@ and
 .BR NETLINK_SELINUX
 groups allow other users to receive messages.
 No groups allow other users to send messages.
+
+.SS Socket options
+To set or get a netlink socket option, call
+.BR getsockopt (2)
+to read or
+.BR setsockopt (2)
+to write the option with the option level argument set to
+.BR SOL_NETLINK .
+Unless otherwise noted,
+.I optval
+is a pointer to an
+.IR int .
+.TP
+.BR NETLINK_PKTINFO " (since Linux 2.6.14)"
+Enable
+.B nl_pktinfo
+control messages for received packets to get the extended
+destination group number.
+.TP
+.BR NETLINK_ADD_MEMBERSHIP ,\  NETLINK_DROP_MEMBERSHIP " (since Linux 2.6.14)"
+Join/leave a group specified by
+.IR optval .
+.\"	commit 9a4595bc7e67962f13232ee55a64e063062c3a99
+.\"	Author: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
+.TP
+.BR NETLINK_LIST_MEMBERSHIPS " (since Linux 4.2)"
+Retrieve all groups a socket is a member of.
+.I optval
+is a pointer to
+.B __u32
+and
+.I optlen
+is the size of the array. The array is filled with the full membership set of the
+socket, and the required array size is returned in
+.I optlen.
+.\"	commit b42be38b2778eda2237fc759e55e3b698b05b315
+.\"	Author: David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+.TP
+.BR NETLINK_BROADCAST_ERROR " (since Linux 2.6.30)"
+When not set,
+.B netlink_broadcast()
+only reports
+.B ESRCH
+errors and silently ignore
+.B NOBUFS
+errors.
+.\"	commit be0c22a46cfb79ab2342bb28fde99afa94ef868e
+.\"	Author: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
+.TP
+.BR NETLINK_NO_ENOBUFS " (since Linux 2.6.30)"
+This flag can be used by unicast and broadcast listeners to avoid receiving
+.B ENOBUFS
+errors.
+.\"	commit 38938bfe3489394e2eed5e40c9bb8f66a2ce1405
+.\"	Author: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
+.TP
+.BR NETLINK_LISTEN_ALL_NSID " (since Linux 4.2)"
+When set, this socket will receive netlink notifications from all network namespaces that
+have an
+.I nsid
+assigned into the network namespace where the socket has been opened. The
+.I nsid
+is sent to user space via an ancillary data.
+.\"	commit 59324cf35aba5336b611074028777838a963d03b
+.\"	Author: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
+.TP
+.BR NETLINK_CAP_ACK " (since Linux 4.2)"
+The kernel may fail to allocate the necessary room for the acknowledgment
+message back to userspace. This option trims off the payload of the original
+netlink message.
+The netlink message header is still included, so the user can guess from the
+sequence number what is the message that has triggered the acknowledgment.
+.\"	commit 0a6a3a23ea6efde079a5b77688541a98bf202721
+.\"	Author: Christophe Ricard <christophe.ricard-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+
 .SH VERSIONS
 The socket interface to netlink is a new feature of Linux 2.2.
 
-- 
2.5.5

--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
