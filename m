From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Merge __load_pointer() and load_pointer() in net/core/filter.c; kernel 2.6.14
Date: Thu, 03 Nov 2005 12:50:29 +1100
Message-ID: <E1EXUFJ-0006nP-00@gondolin.me.apana.org.au>
References: <e626300280b94e0abc26defcc6043b91.kjak@ispwest.com>
Cc: jschlst@samba.org, torvalds@osdl.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, acme@ghostprotocols.net,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030260AbVKCBvI@vger.kernel.org>
To: "Kris Katterjohn" <kjak@users.sourceforge.net>
In-Reply-To: <e626300280b94e0abc26defcc6043b91.kjak@ispwest.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kris Katterjohn <kjak@ispwest.com> wrote:
> Another patch for net/core/filter.c by me. I merged __load_pointer() into
> load_pointer(). I don't see a point in having two seperate functions when
> both functions are really small and load_pointer() calls __load_pointer().
> Renamed the variable "k" to "offset" since that's what it is, and in
> skb_header_pointer() it's "offset".
> 
> This patch is a diff from kernel 2.6.14

This code path is performance-critical so you should benchmark your
changes.

In this particular case, __load_pointer is the unlikely case and
therefore it wasn't inlined.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
