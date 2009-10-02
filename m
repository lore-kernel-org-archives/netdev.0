From: Greg KH <gregkh@suse.de>
Subject: [081/136] netfilter: nf_nat: fix inverted logic for persistent NAT mappings
Date: Thu, 01 Oct 2009 18:17:09 -0700
Message-ID: <20091002012419.291638921@mini.kroah.org>
References: <20091002011548.335611824@mini.kroah.org>
Cc: stable-review@kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	Maximilian Engelhardt <maxi@daemonizer.de>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:33305 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756288AbZJBBdi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 21:33:38 -0400
Content-Disposition: inline; filename=netfilter-nf_nat-fix-inverted-logic-for-persistent-nat-mappings.patch
In-Reply-To: <20091002012911.GA18542@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


2.6.31-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Patrick McHardy <kaber@trash.net>

netfilter: nf_nat: fix inverted logic for persistent NAT mappings

Upstream commit cce5a5c3:

Kernel 2.6.30 introduced a patch [1] for the persistent option in the
netfilter SNAT target. This is exactly what we need here so I had a quick look
at the code and noticed that the patch is wrong. The logic is simply inverted.
The patch below fixes this.

Also note that because of this the default behavior of the SNAT target has
changed since kernel 2.6.30 as it now ignores the destination IP in choosing
the source IP for nating (which should only be the case if the persistent
option is set).

[1] http://git.eu.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=98d500d66cb7940747b424b245fc6a51ecfbf005

Signed-off-by: Maximilian Engelhardt <maxi@daemonizer.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/ipv4/netfilter/nf_nat_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -212,7 +212,7 @@ find_best_ips_proto(struct nf_conntrack_
 	maxip = ntohl(range->max_ip);
 	j = jhash_2words((__force u32)tuple->src.u3.ip,
 			 range->flags & IP_NAT_RANGE_PERSISTENT ?
-				(__force u32)tuple->dst.u3.ip : 0, 0);
+				0 : (__force u32)tuple->dst.u3.ip, 0);
 	j = ((u64)j * (maxip - minip + 1)) >> 32;
 	*var_ipp = htonl(minip + j);
 }


