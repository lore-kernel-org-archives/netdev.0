From: Christoph Hellwig <hch@lst.de>
Subject: Re: old NLMSG_OK fix
Date: Sun, 27 Jun 2004 19:15:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040627171552.GA2797@lst.de>
References: <20040531160427.GA19581@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040531160427.GA19581@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 31, 2004 at 06:04:27PM +0200, Christoph Hellwig wrote:
> I just stumbled over NLMSG_OK and RTA_OK changes in the debian kernel
> package.  It seems they are from
> http://oss.sgi.com/projects/netdev/archive/2000-09/msg00001.html
> 
> Any comments?

ping


--- kernel-source-2.6.6/include/linux/netlink.h	2004-05-10 19:48:07.000000000 +1000
+++ kernel-source-2.6.6-1/include/linux/netlink.h	2004-05-10 22:21:52.000000000 +1000
@@ -73,7 +73,8 @@
 #define NLMSG_DATA(nlh)  ((void*)(((char*)nlh) + NLMSG_LENGTH(0)))
 #define NLMSG_NEXT(nlh,len)	 ((len) -= NLMSG_ALIGN((nlh)->nlmsg_len), \
 				  (struct nlmsghdr*)(((char*)(nlh)) + NLMSG_ALIGN((nlh)->nlmsg_len)))
-#define NLMSG_OK(nlh,len) ((len) > 0 && (nlh)->nlmsg_len >= sizeof(struct nlmsghdr) && \
+#define NLMSG_OK(nlh,len) ((len) >= (int)sizeof(struct nlmsghdr) && \
+			   (nlh)->nlmsg_len >= sizeof(struct nlmsghdr) && \
 			   (nlh)->nlmsg_len <= (len))
 #define NLMSG_PAYLOAD(nlh,len) ((nlh)->nlmsg_len - NLMSG_SPACE((len)))
 
--- kernel-source-2.6.6/include/linux/rtnetlink.h	2004-05-10 19:48:08.000000000 +1000
+++ kernel-source-2.6.6-1/include/linux/rtnetlink.h	2004-05-10 22:21:52.000000000 +1000
@@ -69,7 +69,8 @@
 
 #define RTA_ALIGNTO	4
 #define RTA_ALIGN(len) ( ((len)+RTA_ALIGNTO-1) & ~(RTA_ALIGNTO-1) )
-#define RTA_OK(rta,len) ((len) > 0 && (rta)->rta_len >= sizeof(struct rtattr) && \
+#define RTA_OK(rta,len) ((len) >= (int)sizeof(struct rtattr) && \
+			 (rta)->rta_len >= sizeof(struct rtattr) && \
 			 (rta)->rta_len <= (len))
 #define RTA_NEXT(rta,attrlen)	((attrlen) -= RTA_ALIGN((rta)->rta_len), \
 				 (struct rtattr*)(((char*)(rta)) + RTA_ALIGN((rta)->rta_len)))
