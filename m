From: "Kris Katterjohn" <kjak@ispwest.com>
Subject: Re: [PATCH] Merge __load_pointer() and load_pointer() in net/core/filter.c; kernel 2.6.14
Date: Wed, 2 Nov 2005 18:13:47 -0800
Message-ID: <310a17ad00f84c389e64ae26656ce1a1.kjak@ispwest.com>
Reply-To: "Kris Katterjohn" <kjak@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: jschlst@samba.org, torvalds@osdl.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, acme@ghostprotocols.net,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030283AbVKCCN4@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I wasn't actually changing it to add performance, but to make the code look
cleaner. The new load_pointer() is virtually the same as having the seperate
functions that are currently there, but the code, I think, is "better looking".
If you look at the current net/core/filter.c and then my patched version, the
steps are done in the exact same order and same way, but all in that one
function.

That may sound silly, but I just kept looking at it and asking myself, "Why?"

Of course, one way may still out-perform the other.


Thanks


----- Original Message -----
From: Herbert Xu [mailto:herbert@gondor.apana.org.au]
Sent: 11/2/2005 5:50:29 PM
To: kjak@users.sourceforge.net
Cc: jschlst@samba.org; torvalds@osdl.org; linux-kernel@vger.kernel.org; davem@davemloft.net; acme@ghostprotocols.net; netdev@vger.kernel.org
Subject: Re: [PATCH] Merge __load_pointer() and load_pointer() in net/core/filter.c; kernel 2.6.14

> Kris Katterjohn <kjak@ispwest.com> wrote:
> > Another patch for net/core/filter.c by me. I merged __load_pointer() into
> > load_pointer(). I don't see a point in having two seperate functions when
> > both functions are really small and load_pointer() calls __load_pointer().
> > Renamed the variable "k" to "offset" since that's what it is, and in
> > skb_header_pointer() it's "offset".
> > 
> > This patch is a diff from kernel 2.6.14
> 
> This code path is performance-critical so you should benchmark your
> changes.
> 
> In this particular case, __load_pointer is the unlikely case and
> therefore it wasn't inlined.
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
