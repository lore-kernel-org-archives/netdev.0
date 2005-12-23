From: Greg KH <gregkh@suse.de>
Subject: [patch 07/11] NET: Fix zero-size datagram reception
Date: Fri, 23 Dec 2005 14:27:45 -0800
Message-ID: <20051223222745.GH18252@kroah.com>
References: <20051109182205.294803000@press.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Chuck Wolber <chuckw@quantumlinux.com>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk,
	herbert@gondor.apana.org.au, phillips@istop.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161080AbVLWW2n@vger.kernel.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org
Content-Disposition: inline; filename="fix-zero-size-datagram-reception.patch"
In-Reply-To: <20051223222652.GA18252@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>

The recent rewrite of skb_copy_datagram_iovec broke the reception of
zero-size datagrams.  This patch fixes it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/core/datagram.c |    4 ++++
 1 file changed, 4 insertions(+)

--- linux-2.6.14.1.orig/net/core/datagram.c
+++ linux-2.6.14.1/net/core/datagram.c
@@ -213,6 +213,10 @@ int skb_copy_datagram_iovec(const struct
 {
 	int i, err, fraglen, end = 0;
 	struct sk_buff *next = skb_shinfo(skb)->frag_list;
+
+	if (!len)
+		return 0;
+
 next_skb:
 	fraglen = skb_headlen(skb);
 	i = -1;

--
