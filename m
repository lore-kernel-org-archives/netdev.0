From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: Re: [2.6.12-rc1-mm4] swapped memset arguments
Date: Sun, 3 Apr 2005 00:38:54 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0504030035190.2525@dragon.hyggekrogen.localhost>
References: <74334709.20050402233007@dns.toxicfilms.tv>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261292AbVDBWgj@vger.kernel.org>
To: Maciej Soltysiak <solt2@dns.toxicfilms.tv>
In-Reply-To: <74334709.20050402233007@dns.toxicfilms.tv>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2 Apr 2005, Maciej Soltysiak wrote:

> Hi,
> 
> out of boredom I grepped 2.6.12-rc1-mm4 for swapped memset arguments.
> I found one:
> 
> # grep -nr "memset.*\,\(\ \|\)0\(\ \|\));" *
> net/ieee80211/ieee80211_tx.c:226:       memset(txb, sizeof(struct ieee80211_txb), 0);  
> 
And here's a patch : 


Fix swapped memset() arguments in  net/ieee80211/ieee80211_tx.c  
found by Maciej Soltysiak.

Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>

--- linux-2.6.12-rc1-mm4-orig/net/ieee80211/ieee80211_tx.c	2005-03-31 21:20:08.000000000 +0200
+++ linux-2.6.12-rc1-mm4/net/ieee80211/ieee80211_tx.c	2005-04-03 00:34:22.000000000 +0200
@@ -223,7 +223,7 @@ struct ieee80211_txb *ieee80211_alloc_tx
 	if (!txb)
 		return NULL;
 
-	memset(txb, sizeof(struct ieee80211_txb), 0);
+	memset(txb, 0, sizeof(struct ieee80211_txb));
 	txb->nr_frags = nr_frags;
 	txb->frag_size = txb_size;
 
