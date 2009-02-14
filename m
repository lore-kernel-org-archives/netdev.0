From: Greg KH <gregkh@suse.de>
Subject: [patch 45/48] netfilter: fix tuple inversion for Node information
	request
Date: Fri, 13 Feb 2009 17:13:51 -0800
Message-ID: <20090214011351.GT17706@kroah.com>
References: <20090214010805.419403436@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>, Willy Tarreau <w@1wt.eu>,
	Rodrigo Rubira Branco <rbranco@la.checkpoint.com>,
	Jake Edge <jake@lwn.net>, Eugene Teo <eteo@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	davem@davemloft.net, Eric Leblond <eric@inl.fr>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:50709 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762720AbZBNBQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Feb 2009 20:16:44 -0500
Content-Disposition: inline; filename="netfilter-fix-tuple-inversion-for-node-information-request.patch"
In-Reply-To: <20090214011208.GA17706@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.28-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Eric Leblond <eric@inl.fr>

netfilter: fix tuple inversion for Node information request

Upstream commit: a51f42f3c

The patch fixes a typo in the inverse mapping of Node Information
request. Following draft-ietf-ipngwg-icmp-name-lookups-09, "Querier"
sends a type 139 (ICMPV6_NI_QUERY) packet to "Responder" which answer
with a type 140 (ICMPV6_NI_REPLY) packet.

Signed-off-by: Eric Leblond <eric@inl.fr>
Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -49,8 +49,8 @@ static bool icmpv6_pkt_to_tuple(const st
 static const u_int8_t invmap[] = {
 	[ICMPV6_ECHO_REQUEST - 128]	= ICMPV6_ECHO_REPLY + 1,
 	[ICMPV6_ECHO_REPLY - 128]	= ICMPV6_ECHO_REQUEST + 1,
-	[ICMPV6_NI_QUERY - 128]		= ICMPV6_NI_QUERY + 1,
-	[ICMPV6_NI_REPLY - 128]		= ICMPV6_NI_REPLY +1
+	[ICMPV6_NI_QUERY - 128]		= ICMPV6_NI_REPLY + 1,
+	[ICMPV6_NI_REPLY - 128]		= ICMPV6_NI_QUERY +1
 };
 
 static bool icmpv6_invert_tuple(struct nf_conntrack_tuple *tuple,

