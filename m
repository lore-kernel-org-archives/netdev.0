From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv4] netfilter: add CHECKSUM target
Date: Thu, 15 Jul 2010 20:42:16 +0300
Message-ID: <20100715174216.GA16216@redhat.com>
References: <20100715115217.GA6737@redhat.com>
 <4C3F27A2.3030207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Daniel P. Berrange" <berrange@redhat.com>,
	Jes Sorensen <Jes.Sorensen@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jan Engelhardt <jengelh@medozas.de>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59815 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933810Ab0GORrv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jul 2010 13:47:51 -0400
Content-Disposition: inline
In-Reply-To: <4C3F27A2.3030207@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 15, 2010 at 05:22:10PM +0200, Patrick McHardy wrote:
> Am 15.07.2010 13:52, schrieb Michael S. Tsirkin:
> > This adds a `CHECKSUM' target, which can be used in the iptables mangle
> > table.
> > 
> > You can use this target to compute and fill in the checksum in
> > a packet that lacks a checksum.  This is particularly useful,
> > if you need to work around old applications such as dhcp clients,
> > that do not work well with checksum offloads, but don't want to
> > disable checksum offload in your device.
> > 
> > The problem happens in the field with virtualized applications.
> > For reference, see Red Hat bz 605555, as well as
> > http://www.spinics.net/lists/kvm/msg37660.html
> > 
> > Typical expected use (helps old dhclient binary running in a VM):
> > iptables -A POSTROUTING -t mangle -p udp --dport bootpc \
> > 	-j CHECKSUM --checksum-fill
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > Includes fixes by Jan Engelhardt <jengelh@medozas.de>
> 
> Applied, thanks Michael.

I forgot to export the header. And once I added it, I got warning
on header_check, so here's a fixup. Sorry about the noise.

netfilter: correct CHECKSUM header and export it

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

--

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index 48767cd..0c3098f 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -3,6 +3,7 @@ header-y += nf_conntrack_tuple_common.h
 header-y += nfnetlink_conntrack.h
 header-y += nfnetlink_log.h
 header-y += nfnetlink_queue.h
+header-y += xt_CHECKSUM.h
 header-y += xt_CLASSIFY.h
 header-y += xt_CONNMARK.h
 header-y += xt_CONNSECMARK.h
diff --git a/include/linux/netfilter/xt_CHECKSUM.h b/include/linux/netfilter/xt_CHECKSUM.h
index 3b4fb77..9a2e466 100644
--- a/include/linux/netfilter/xt_CHECKSUM.h
+++ b/include/linux/netfilter/xt_CHECKSUM.h
@@ -6,8 +6,10 @@
  *
  * This software is distributed under GNU GPL v2, 1991
 */
-#ifndef _IPT_CHECKSUM_TARGET_H
-#define _IPT_CHECKSUM_TARGET_H
+#ifndef _XT_CHECKSUM_TARGET_H
+#define _XT_CHECKSUM_TARGET_H
+
+#include <linux/types.h>
 
 #define XT_CHECKSUM_OP_FILL	0x01	/* fill in checksum in IP header */
 
@@ -15,4 +17,4 @@ struct xt_CHECKSUM_info {
 	__u8 operation;	/* bitset of operations */
 };
 
-#endif /* _IPT_CHECKSUM_TARGET_H */
+#endif /* _XT_CHECKSUM_TARGET_H */
