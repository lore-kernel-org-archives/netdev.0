From: David Miller <davem@davemloft.net>
Subject: Re: include/linux/ipv6.h, struct ipv6_devconf leaks to userspace
Date: Mon, 21 Jul 2008 13:42:00 -0700 (PDT)
Message-ID: <20080721.134200.195306719.davem@davemloft.net>
References: <20080721123430.GA28599@aepfle.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: olaf@aepfle.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41987
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755461AbYGUUmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 16:42:00 -0400
In-Reply-To: <20080721123430.GA28599@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olaf Hering <olaf@aepfle.de>
Date: Mon, 21 Jul 2008 14:34:30 +0200

> 
> Found by make O="$header_dir" headers_install_all in 2.6.26:
> 
> struct ipv6_devconf contains conditional members, guarded by CONFIG_*.
> 
> Please move the struct into #ifdef __KERNEL__

I've applied the following patch, let me know if it doesn't
fix the problem.

Thanks.

ipv6: __KERNEL__ ifdef struct ipv6_devconf

Based upon a report by Olaf Hering.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/ipv6.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 391ad08..641e026 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -123,6 +123,7 @@ struct ipv6hdr {
 	struct	in6_addr	daddr;
 };
 
+#ifdef __KERNEL__
 /*
  * This structure contains configuration options per IPv6 link.
  */
@@ -167,6 +168,7 @@ struct ipv6_devconf {
 	__s32		accept_dad;
 	void		*sysctl;
 };
+#endif
 
 /* index values for the variables in ipv6_devconf */
 enum {
-- 
1.5.6.4.433.g09651

