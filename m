From: Greg KH <gregkh@suse.de>
Subject: [patch 40/47] netfilter: xt_sctp: sctp chunk mapping doesnt work
Date: Fri, 13 Feb 2009 16:59:22 -0800
Message-ID: <20090214005922.GO11282@kroah.com>
References: <20090214005130.617401075@mini.kroah.org>
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
	davem@davemloft.net, Qu Haoran <haoran.qu@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename="netfilter-xt_sctp-sctp-chunk-mapping-doesn-t-work.patch"
In-Reply-To: <20090214005726.GA11282@kroah.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2.6.27-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Qu Haoran <haoran.qu@6wind.com>

netfilter: xt_sctp: sctp chunk mapping doesn't work

Upstream commit: d4e2675a

When user tries to map all chunks given in argument, kernel
works on a copy of the chunkmap, but at the end it doesn't
check the copy, but the orginal one.

Signed-off-by: Qu Haoran <haoran.qu@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/netfilter/xt_sctp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/netfilter/xt_sctp.c
+++ b/net/netfilter/xt_sctp.c
@@ -105,7 +105,7 @@ match_packet(const struct sk_buff *skb,
 
 	switch (chunk_match_type) {
 	case SCTP_CHUNK_MATCH_ALL:
-		return SCTP_CHUNKMAP_IS_CLEAR(info->chunkmap);
+		return SCTP_CHUNKMAP_IS_CLEAR(chunkmapcopy);
 	case SCTP_CHUNK_MATCH_ANY:
 		return false;
 	case SCTP_CHUNK_MATCH_ONLY:

