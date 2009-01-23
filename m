From: Greg KH <gregkh@suse.de>
Subject: [patch 29/46] netfilter: ebtables: fix inversion in match code
Date: Thu, 22 Jan 2009 17:12:33 -0800
Message-ID: <20090123011233.GD19756@kroah.com>
References: <20090123010651.683741823@mini.kroah.org>
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
	davem@davemloft.net, Jan Engelhardt <jengelh@medozas.de>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:50694 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756380AbZAWBPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 20:15:07 -0500
Content-Disposition: inline; filename="netfilter-ebtables-fix-inversion-in-match-code.patch"
In-Reply-To: <20090123011110.GA19756@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.28-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Patrick McHardy <kaber@trash.net>

Upstream commit d61ba9f:

Commit 8cc784ee (netfilter: change return types of match functions
for ebtables extensions) broke ebtables matches by inverting the
sense of match/nomatch.

Reported-by: Matt Cross <matthltc@us.ibm.com>
Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/bridge/netfilter/ebtables.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -80,7 +80,7 @@ static inline int ebt_do_match (struct e
 {
 	par->match     = m->u.match;
 	par->matchinfo = m->data;
-	return m->u.match->match(skb, par);
+	return m->u.match->match(skb, par) ? EBT_MATCH : EBT_NOMATCH;
 }
 
 static inline int ebt_dev_check(char *entry, const struct net_device *device)

