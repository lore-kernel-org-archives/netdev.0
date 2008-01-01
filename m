From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Tue, 1 Jan 2008 13:59:12 +0100
Message-ID: <64bb37e0801010459h68976d56i21d505eb2817f1ac@mail.gmail.com>
References: <20071222233056.d652743e.akpm@linux-foundation.org>
	 <64bb37e0712230827m7d368e2l3174f3b4396d09c1@mail.gmail.com>
	 <64bb37e0712281453y4aac82b7h7acc8ec314ca6e3e@mail.gmail.com>
	 <20071228150746.42b3bbc0.akpm@linux-foundation.org>
	 <64bb37e0712290851r6d41768dk270e47884713a3de@mail.gmail.com>
	 <20071230013021.GA13603@gondor.apana.org.au>
	 <64bb37e0712291934o77a3d365h56c9c31ac8437469@mail.gmail.com>
	 <64bb37e0712311215x519b10e9kd51eb745b3b7290a@mail.gmail.com>
	 <20080101120406.GA27209@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, "Neil Brown" <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	"Tom Tucker" <tom@opengridcomputing.com>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:22777 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664AbYAAM7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 07:59:14 -0500
Received: by py-out-1112.google.com with SMTP id u52so9433884pyb.10
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2008 04:59:13 -0800 (PST)
In-Reply-To: <20080101120406.GA27209@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 1, 2008 1:04 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Mon, Dec 31, 2007 at 09:15:19PM +0100, Torsten Kaiser wrote:
> >
> > I then tried to "fix" it with this suspect.
> > I changed "skb_release_all(dst);" back to "skb_release_data(dst);" in
> > skb_morph() (net/core/skbuff.c).
>
> Check /proc/net/snmp to see if you're getting any fragments, if not
> then skb_morph shouldn't even be getting called.

OK, thanks for that hint.
I look at this after my next tests.

> > I'm now at 205 of 210 packages completed without a further hang. I
> > also do not see an obvious memory leak.
>
> In any case, I suspect the cause of your problem is that somebody
> somewhere is doing a double-free on an skb.

Is there any debug option I could turn on to catch this?

Hmm... __alloc_skb() uses kmem_cache_alloc_node() and I did run
-rc3-mm2 a long time with slub_debug=FZP and that did not catch
anything. Shouldn't the poisoning catch that? (Sorry if this question
is stupid, but while I can read C, I'm not a kernel expert)

> Since you're the only person who can reproduce this, we really need
> your help to track this down.  Since bisecting the mm tree is not
> practical, you could start by checking whether the bug is in mm only
> or whether it affects rc6 too.

I will try -rc6-mm1 and vanilla -rc6 and report back.

Torsten
