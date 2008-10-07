From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm, for adaptive dcache hash table sizing (resend)
Date: Wed, 8 Oct 2008 03:39:39 +1100
Message-ID: <200810080339.40300.nickpiggin@yahoo.com.au>
References: <20081007064834.GA5959@wotan.suse.de> <20081007071827.GB5010@infradead.org> <18667.33351.854693.368568@harpo.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	Nick Piggin <npiggin@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	netdev@vger.kernel.org, Paul McKenney <paulmck@us.ibm.com>
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp114.mail.mud.yahoo.com ([209.191.84.67]:24560 "HELO
	smtp114.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753272AbYJGQjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 12:39:49 -0400
In-Reply-To: <18667.33351.854693.368568@harpo.it.uu.se>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 08 October 2008 02:37, Mikael Pettersson wrote:

> I missed the first post, but loooking at the patch it seems
> somewhat complex.

It is complex, but relatively self-contained, ie. it doesn't affect
the actual code that performs hash lookups very much (although there
can be some impact on atomicity if we have to consider something like
a full table traversal like the rt hash).


> How does this relate to traditional incremental hash tables
> like extensible hashing or linear hashing (not to be confused
> with linear probing)? In linear hashing a resize only affects
> a single collision chain at a time, and reads from other chains
> than the one being resized are unaffected.

I haven't actually seen any real implementations of those things.
AFAICS they don't exactly deal with concurrency. They are also likely
to be more costly to operate on, versus a well sized simple hash
table.
