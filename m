From: Greg KH <gregkh@suse.de>
Subject: [patch 08/20] ipx: header length validation needed
Date: Mon, 21 Aug 2006 11:46:39 -0700
Message-ID: <20060821184639.GI21938@kroah.com>
References: <20060821183818.155091391@quad.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	acme@ghostprotocols.net, Stephen Hemminger <shemminger@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750738AbWHUSsg@vger.kernel.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	David Miller <davem@davemloft.net>
Content-Disposition: inline; filename="ipx-header-length-validation-needed.patch"
In-Reply-To: <20060821184527.GA21938@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Stephen Hemminger <shemminger@osdl.org>

This patch will linearize and check there is enough data.
It handles the pprop case as well as avoiding a whole audit of
the routing code.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 net/ipx/af_ipx.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-2.6.17.8.orig/net/ipx/af_ipx.c
+++ linux-2.6.17.8/net/ipx/af_ipx.c
@@ -1647,7 +1647,8 @@ static int ipx_rcv(struct sk_buff *skb, 
 	ipx_pktsize	= ntohs(ipx->ipx_pktsize);
 	
 	/* Too small or invalid header? */
-	if (ipx_pktsize < sizeof(struct ipxhdr) || ipx_pktsize > skb->len)
+	if (ipx_pktsize < sizeof(struct ipxhdr)
+	   || !pskb_may_pull(skb, ipx_pktsize))
 		goto drop;
                         
 	if (ipx->ipx_checksum != IPX_NO_CHECKSUM &&

--
