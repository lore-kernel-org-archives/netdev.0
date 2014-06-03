From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] LISP: Locator/Identifier Separation Protocol
Date: Tue, 3 Jun 2014 15:22:13 -0700
Message-ID: <20140603152213.426ce22b@nehalam.linuxnetplumber.net>
References: <E5B7A820-EF96-4F50-81F8-DE7714105D89@logicalelegance.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christopher White <chris@logicalelegance.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:37448 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933038AbaFCWWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 18:22:17 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so5235270pdi.27
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 15:22:16 -0700 (PDT)
In-Reply-To: <E5B7A820-EF96-4F50-81F8-DE7714105D89@logicalelegance.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 May 2014 14:05:29 -0700
Christopher White <chris@logicalelegance.com> wrote:

> This is a static tunnel implementation of LISP as described in RFC 6830:
>   http://tools.ietf.org/html/rfc6830
> 
> This driver provides point-to-point LISP dataplane
> encapsulation/decapsulation for statically configured endpoints. It provides
> support for IPv4 in IPv4 and IPv6 in IPv4. IPv6 outer headers are not
> supported yet. Instance ID is supported on a per device basis.
> 
> This implementation has been tested against LISPMob.

Checkpatch reports many problems with this patch.
The biggest of which is missing signed-off by!

WARNING: Use a single space after To:
#28: 
To:	netdev@vger.kernel.org

WARNING: LINUX_VERSION_CODE should be avoided, code should be for the version to which it is merged
#137: FILE: drivers/net/lisp.c:43:
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 36)

WARNING: LINUX_VERSION_CODE should be avoided, code should be for the version to which it is merged
#145: FILE: drivers/net/lisp.c:51:
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 33)

WARNING: networking block comments put the trailing */ on a separate line
#158: FILE: drivers/net/lisp.c:64:
+	 * router expect RT_TOS bits only. */

WARNING: LINUX_VERSION_CODE should be avoided, code should be for the version to which it is merged
#160: FILE: drivers/net/lisp.c:66:
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 39)

ERROR: spaces required around that '=' (ctx:WxV)
#161: FILE: drivers/net/lisp.c:67:
+	struct flowi fl = { .nl_u			={ .ip4_u = {
 	                         			^

WARNING: line over 80 characters
#162: FILE: drivers/net/lisp.c:68:
+								 .daddr		   = daddr,

WARNING: line over 80 characters
#163: FILE: drivers/net/lisp.c:69:
+								 .saddr		   = *saddr,

WARNING: line over 80 characters
#164: FILE: drivers/net/lisp.c:70:
+								 .tos		   = RT_TOS(tos)

ERROR: "foo *		bar" should be "foo *bar"
#265: FILE: drivers/net/lisp.c:171:
+	lisp_rcv_t *		rcv;

ERROR: "foo *			bar" should be "foo *bar"
#266: FILE: drivers/net/lisp.c:172:
+	void *			data;

ERROR: "foo *	bar" should be "foo *bar"
#268: FILE: drivers/net/lisp.c:174:
+	struct      socket *	sock;

ERROR: "foo *	bar" should be "foo *bar"
#278: FILE: drivers/net/lisp.c:184:
+	struct net_device *	dev;

ERROR: "foo *	bar" should be "foo *bar"
#280: FILE: drivers/net/lisp.c:186:
+	struct lisp_sock *	rcv_socket;     /* Input port */

WARNING: line over 80 characters
#281: FILE: drivers/net/lisp.c:187:
+	__be16			rcv_port;       /* Port to listen to to receive packets */

WARNING: line over 80 characters
#282: FILE: drivers/net/lisp.c:188:
+	__be16			encap_port;     /* Destination port for encapsulating packets */

WARNING: networking uses a blank line after declarations
#408: FILE: drivers/net/lisp.c:314:
+		int err = skb_unclone(skb, GFP_ATOMIC);
+		if (unlikely(err))

WARNING: line over 80 characters
#430: FILE: drivers/net/lisp.c:336:
+		hash = jhash2((const u32 *)skb->data, 2 * ETH_ALEN, 0);  // Not great, stolen from vxlan, what should we use?

ERROR: do not use C99 // comments
#430: FILE: drivers/net/lisp.c:336:
+		hash = jhash2((const u32 *)skb->data, 2 * ETH_ALEN, 0);  // Not great, stolen from vxlan, what should we use?

ERROR: "foo *	bar" should be "foo *bar"
#437: FILE: drivers/net/lisp.c:343:
+static void lisp_build_header(const struct lisp_dev *	dev,

ERROR: "foo *		bar" should be "foo *bar"
#438: FILE: drivers/net/lisp.c:344:
+			      struct sk_buff *		skb)

WARNING: line over 80 characters
#450: FILE: drivers/net/lisp.c:356:
+	lisph->nonce_present = 0;               /* We don't support echo nonce algorithm */

WARNING: line over 80 characters
#453: FILE: drivers/net/lisp.c:359:
+	lisph->map_version_present = 0;         /* No mapping versioning, nonce instead */

WARNING: line over 80 characters
#454: FILE: drivers/net/lisp.c:360:
+	lisph->instance_id_present = 1;         /* Store the tun_id as Instance ID  */

ERROR: do not use C99 // comments
#461: FILE: drivers/net/lisp.c:367:
+	// Include the instance ID for this device

WARNING: networking block comments don't use an empty /* line, use /* Comment...
#482: FILE: drivers/net/lisp.c:388:
+/*
+ * Transmit local sourced packets with LISP encapsulation

WARNING: line over 80 characters
#587: FILE: drivers/net/lisp.c:493:
+	if ((skb->ip_summed != CHECKSUM_UNNECESSARY && skb->ip_summed != CHECKSUM_PARTIAL) ||

ERROR: "foo * bar" should be "foo *bar"
#606: FILE: drivers/net/lisp.c:512:
+static void lisp_rcv(struct lisp_sock * s,

ERROR: "foo *	bar" should be "foo *bar"
#607: FILE: drivers/net/lisp.c:513:
+		     struct sk_buff *	skb)

WARNING: printk() should include KERN_ facility level
#637: FILE: drivers/net/lisp.c:543:
+		printk("Instance ID 0x%x not found\n", iid);

WARNING: line over 80 characters
#787: FILE: drivers/net/lisp.c:693:
+	struct lisp_dev *lispdev = container_of(work, struct lisp_dev, sock_work);

WARNING: line over 80 characters
#818: FILE: drivers/net/lisp.c:724:
+	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_NETNS_LOCAL | NETIF_F_RXCSUM |

WARNING: line over 80 characters
#820: FILE: drivers/net/lisp.c:726:
+	dev->hw_features |= (NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_GSO_SOFTWARE);

WARNING: line over 80 characters
#853: FILE: drivers/net/lisp.c:759:
+		lispdev->local.sin.sin_addr.s_addr = nla_get_be32(data[IFLA_LISP_LOCAL]);

WARNING: line over 80 characters
#858: FILE: drivers/net/lisp.c:764:
+		lispdev->encap_port = ntohs(nla_get_be16(data[IFLA_LISP_ENCAP_PORT]));

WARNING: line over 80 characters
#861: FILE: drivers/net/lisp.c:767:
+		lispdev->rcv_port = ntohs(nla_get_be16(data[IFLA_LISP_LISTEN_PORT]));

WARNING: line over 80 characters
#864: FILE: drivers/net/lisp.c:770:
+		lispdev->remote.sin.sin_addr.s_addr = nla_get_be32(data[IFLA_LISP_REMOTE]);

ERROR: code indent should use tabs where possible
#898: FILE: drivers/net/lisp.c:804:
+^I        /* IFLA_LISP_IID */$

ERROR: code indent should use tabs where possible
#900: FILE: drivers/net/lisp.c:806:
+^I        /* IFLA_LISP_LOCAL */$

ERROR: code indent should use tabs where possible
#902: FILE: drivers/net/lisp.c:808:
+^I        /* IFLA_LISP_LOCAL6 */$

ERROR: code indent should use tabs where possible
#904: FILE: drivers/net/lisp.c:810:
+^I        /* IFLA_LISP_REMOTE */$

ERROR: code indent should use tabs where possible
#906: FILE: drivers/net/lisp.c:812:
+^I        /* IFLA_LISP_REMOTE6 */$

ERROR: code indent should use tabs where possible
#908: FILE: drivers/net/lisp.c:814:
+^I        /* IFLA_LISP_ENCAP_PORT */$

ERROR: code indent should use tabs where possible
#910: FILE: drivers/net/lisp.c:816:
+^I        /* IFLA_LISP_LISTEN_PORT */$

ERROR: code indent should use tabs where possible
#912: FILE: drivers/net/lisp.c:818:
+^I        /* IFLA_LISP_TOS */$

ERROR: code indent should use tabs where possible
#914: FILE: drivers/net/lisp.c:820:
+^I        /* IFLA_LISP_TTL */$

WARNING: networking block comments don't use an empty /* line, use /* Comment...
#920: FILE: drivers/net/lisp.c:826:
+/*
+ * Fill attributes into skb

ERROR: do not use C99 // comments
#926: FILE: drivers/net/lisp.c:832:
+	// NEED V6 OPTIONS XXX TBD

WARNING: line over 80 characters
#928: FILE: drivers/net/lisp.c:834:
+	    nla_put_u32(skb, IFLA_LISP_LOCAL, lispdev->local.sin.sin_addr.s_addr) ||

WARNING: line over 80 characters
#929: FILE: drivers/net/lisp.c:835:
+	    nla_put_u32(skb, IFLA_LISP_REMOTE, lispdev->remote.sin.sin_addr.s_addr) ||

WARNING: Prefer [subsystem eg: netdev]_info([subsystem]dev, ... then dev_info(dev, ... then pr_info(...  to printk(KERN_INFO ...
#1018: FILE: drivers/net/lisp.c:924:
+	printk(KERN_INFO "Cleaning up module.\n");

ERROR: Missing Signed-off-by: line(s)

total: 23 errors, 29 warnings, 984 lines checked

NOTE: whitespace errors detected, you may wish to use scripts/cleanpatch or
      scripts/cleanfile

/tmp/lisp.patch has style problems, please review.

If any of these errors are false positives, please report
them to the maintainer, see CHECKPATCH in MAINTAINERS.
