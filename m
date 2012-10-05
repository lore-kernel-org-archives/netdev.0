From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: kernel 3.2.27 on arm: WARNING: at mm/page_alloc.c:2109
 __alloc_pages_nodemask+0x1d4/0x68c()
Date: Fri, 05 Oct 2012 14:51:49 +0200
Message-ID: <1349441509.28867.17.camel@sakura.staff.proxad.net>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
	 <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
	 <1349366521.2532.12.camel@sakura.staff.proxad.net>
	 <1349368171.16011.79.camel@edumazet-glaptop>
	 <1349422868.21172.38.camel@edumazet-glaptop>
	 <1349434194.16710.44.camel@sakura.staff.proxad.net>
	 <1349439732.21172.52.camel@edumazet-glaptop>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: David Madore <david+ml@madore.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349439732.21172.52.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2012-10-05 at 14:22 +0200, Eric Dumazet wrote:

> Yes, but the idea of the patch was to _avoid_ next pskb_expand_head()
> calls...

yes but we cannot be sure of that, the caller may not have a good idea
of the headroom needed for the whole lifetime of the skb

it's better to think we will reduce number of calls, not avoid them

that's why I think doubling the size each time is dangerous, since we
silently request bigger and bigger allocations if an skb takes an
unoptimized path

> Hmm, 
> 
> this changes nothing assuming current_end == skb_end_offset(skb)
> and current_head = skb->head

My idea was to leave skb->end at its last position even if we grow
skb->head.

Since we have a way to know the current allocation size of skb->head,
further pskb_expand_head() calls to request tailroom would just push
skb->tail & skb->end together if that fits in current ksize().

I've not looked at recent changes in mainline, since you changed how
skb->head is managed, that may be totally impossible.

Your proposed changed API change to expand_head will fill this anyway.

> New convention would be : pass number of needed bytes after current
> tail, not after current end.

Fully agree on this

-- 
Maxime
