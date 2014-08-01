From: Karoly Kemeny <karoly.kemeny@gmail.com>
Subject: [PATCH 1/2] net: socket.h structures documentation
Date: Fri,  1 Aug 2014 23:31:22 +0200
Message-ID: <1406928683-4317-1-git-send-email-karoly.kemeny@gmail.com>
Cc: Karoly Kemeny <karoly.kemeny@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	linux-doc@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Karoly Kemeny <karoly.kemeny@gmail.com>
---
 include/linux/socket.h | 78 ++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 57 insertions(+), 21 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index ec538fc..18c225a 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -25,15 +25,27 @@ typedef __kernel_sa_family_t	sa_family_t;
 /*
  *	1003.1g requires sa_family_t and that sa_data is char.
  */
- 
+
+/**
+ * 	struct sockaddr - A common base for address structures
+ * 	@sa_family:	 address family, AF_xxx
+ * 	@sa_data:	14 bytes of protocol address
+ */
+
 struct sockaddr {
-	sa_family_t	sa_family;	/* address family, AF_xxx	*/
-	char		sa_data[14];	/* 14 bytes of protocol address	*/
+	sa_family_t	sa_family;
+	char		sa_data[14];
 };
 
+/**
+ * 	struct linger -	Linger options on socket closing
+ * 	@l_onoff:	Linger active
+ * 	@l_linger:	How long to linger for
+ */
+
 struct linger {
-	int		l_onoff;	/* Linger active		*/
-	int		l_linger;	/* How long to linger for	*/
+	int		l_onoff;
+	int		l_linger;
 };
 
 #define sockaddr_storage __kernel_sockaddr_storage
@@ -43,33 +55,53 @@ struct linger {
  *	system, not 4.3. Thus msg_accrights(len) are now missing. They
  *	belong in an obscure libc emulation or the bin.
  */
- 
+
+/**
+ * 	struct msghdr - Includes the data blocks to send or to fill for
+ * 			sendmsg() and recvmsg(), and some other parameters
+ * 	@msg_name:	ptr to socket address structure
+ * 	@msg_namelen:	size of socket address structure
+ * 	@msg_iov:	scatter/gather array
+ * 	@msg_iovlen:	number of elements in msg_iov
+ * 	@msg_control:	ancillary data
+ * 	@msg_controllen: ancillary data buffer length
+ * 	@msg_flags:	flags on received message
+ */
+
 struct msghdr {
-	void		*msg_name;	/* ptr to socket address structure */
-	int		msg_namelen;	/* size of socket address structure */
-	struct iovec	*msg_iov;	/* scatter/gather array */
-	__kernel_size_t	msg_iovlen;	/* # elements in msg_iov */
-	void		*msg_control;	/* ancillary data */
-	__kernel_size_t	msg_controllen;	/* ancillary data buffer length */
-	unsigned int	msg_flags;	/* flags on received message */
+	void		*msg_name;
+	int		msg_namelen;
+	struct iovec	*msg_iov;
+	__kernel_size_t	msg_iovlen;
+	void		*msg_control;
+	__kernel_size_t	msg_controllen;
+	unsigned int	msg_flags;
 };
 
-/* For recvmmsg/sendmmsg */
+/**
+ * struct mmsghdr - wrapper for recvmmsg/sendmmsg
+ * @msg_hdr:	the real message header embedded
+ * @msg_len:	length of the message header
+ */
+
 struct mmsghdr {
 	struct msghdr   msg_hdr;
 	unsigned int        msg_len;
 };
 
-/*
- *	POSIX 1003.1g - ancillary data object information
- *	Ancillary data consits of a sequence of pairs of
- *	(cmsghdr, cmsg_data[])
+/**
+ *	struct cmsghdr - POSIX 1003.1g - ancillary data object information
+ *			 Ancillary data consists of a sequence of pairs of
+ *			 (cmsghdr, cmsg_data[])
+ *	@cmsg_len:	data byte count, including hdr
+ *	@cmsg_level:	originating protocol
+ *	@cmsg_type:	protocol specific type
  */
 
 struct cmsghdr {
-	__kernel_size_t	cmsg_len;	/* data byte count, including hdr */
-        int		cmsg_level;	/* originating protocol */
-        int		cmsg_type;	/* protocol-specific type */
+	__kernel_size_t	cmsg_len;
+        int		cmsg_level;
+        int		cmsg_type;
 };
 
 /*
@@ -131,6 +163,10 @@ static inline struct cmsghdr * cmsg_nxthdr (struct msghdr *__msg, struct cmsghdr
 #define SCM_CREDENTIALS 0x02		/* rw: struct ucred		*/
 #define SCM_SECURITY	0x03		/* rw: security label		*/
 
+/**
+ *  struct ucred - credentials represented an a struct in the ancilliary message
+ */
+
 struct ucred {
 	__u32	pid;
 	__u32	uid;
-- 
1.9.1

