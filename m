From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Restore API compatibility of address and neighbour
 bits
Date: Fri, 08 Dec 2006 17:14:55 -0800 (PST)
Message-ID: <20061208.171455.11932070.davem@davemloft.net>
References: <20061208.134752.131916271.davem@davemloft.net>
	<20061208215206.GA29601@nevyn.them.org>
	<20061208.164345.71119524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefan@loplof.de, tgraf@suug.ch, dwmw2@infradead.org,
	joseph@codesourcery.com, netdev@vger.kernel.org,
	libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35509
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761333AbWLIBOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 20:14:46 -0500
To: drow@false.org
In-Reply-To: <20061208.164345.71119524.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Fri, 08 Dec 2006 16:43:45 -0800 (PST)

> hohum... guess we'll need to bring back that crap too...
> 
> i'll take care of this

Here's what I'll push into the tree.

commit c0279128f20aa3580b0b43aaa49f351f6bad5f30
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Fri Dec 8 17:05:13 2006 -0800

    [NETLINK]: Put {IFA,IFLA}_{RTA,PAYLOAD} macros back for userspace.
    
    GLIBC uses them etc.
    
    They are guarded by ifndef __KERNEL__ so nobody will start
    accidently using them in the kernel again, it's just for
    userspace.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index dbe8f61..d557e4c 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -52,4 +52,10 @@ struct ifa_cacheinfo
 	__u32	tstamp; /* updated timestamp, hundredths of seconds */
 };
 
+/* backwards compatibility for userspace */
+#ifndef __KERNEL__
+#define IFA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifaddrmsg))))
+#define IFA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifaddrmsg))
+#endif
+
 #endif
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index e963a07..35ed3b5 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -82,6 +82,12 @@ #define IFLA_WEIGHT IFLA_WEIGHT
 
 #define IFLA_MAX (__IFLA_MAX - 1)
 
+/* backwards compatibility for userspace */
+#ifndef __KERNEL__
+#define IFLA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
+#define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
+#endif
+
 /* ifi_flags.
 
    IFF_* flags.
