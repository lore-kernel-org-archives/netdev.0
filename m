From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [NETLINK]: Restore API compatibility of address and neighbour
 bits
Date: Fri, 8 Dec 2006 15:25:18 +0100 (MET)
Message-ID: <200612081526.12651.stefan@loplof.de>
References: <200612062033.34754.stefan@loplof.de>
 <20061207.025140.75779834.davem@davemloft.net>
 <20061207105502.GJ8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dwmw2@infradead.org,
	joseph@codesourcery.com, netdev@vger.kernel.org,
	libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p07-ob.rzone.de ([81.169.146.190]:17935 "EHLO
	mo-p07-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760741AbWLHO1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 09:27:21 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061207105502.GJ8693@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Thomas,

Am Donnerstag, 7. Dezember 2006 11:55 schrieb Thomas Graf:

> --- net-2.6.orig/include/linux/rtnetlink.h	2006-12-07 11:25:29.000000000
> +0100 +++ net-2.6/include/linux/rtnetlink.h	2006-12-07 11:32:25.000000000
> +0100 @@ -3,6 +3,8 @@
>
>  #include <linux/netlink.h>
>  #include <linux/if_link.h>
> +#include <linux/if_addr.h>
> +#include <linux/neighbour.h>
>
>  /****
>   *		Routing/neighbour discovery messages.

The _RTA and _PAYLOAD-macros are also part of userspace headers and need to be
restored. Both dhcpclient and quagga need at least IFA_RTA and IFLA_RTA to
compile, but there may be more macros than in the following patch. You may want
to look at keepalived, iproute, ...

Stefan

--- linux-2.6.19/include/linux/if_addr.h.orig	2006-12-08 14:08:29.000000000 +0100
+++ linux-2.6.19/include/linux/if_addr.h	2006-12-08 15:16:59.000000000 +0100
@@ -52,4 +52,12 @@
 	__u32	tstamp; /* updated timestamp, hundredths of seconds */
 };
 
+#ifndef __KERNEL__
+
+/* Userspace header compatibility */
+#define IFA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifaddrmsg))))
+#define IFA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifaddrmsg))
+
+#endif
+
 #endif
--- linux-2.6.19/include/linux/if_link.h.orig	2006-12-08 14:08:29.000000000 +0100
+++ linux-2.6.19/include/linux/if_link.h	2006-12-08 15:16:47.000000000 +0100
@@ -133,4 +133,12 @@
 	__u32	retrans_time;
 };
 
+#ifndef __KERNEL__
+
+/* Userspace header compatibility */
+#define IFLA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
+#define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
+
+#endif
+
 #endif /* _LINUX_IF_LINK_H */


