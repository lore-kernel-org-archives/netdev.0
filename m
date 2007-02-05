From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] HTB O(1) class lookup
Date: Mon, 5 Feb 2007 11:16:38 +0100
Message-ID: <20070205101637.GB1863@ff.dom.local>
References: <p73r6tanmhk.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Lodal <simonl@parknet.dk>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org, lartc@mailman.ds9a.nl
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:56148 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751433AbXBEKNp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 05:13:45 -0500
Content-Disposition: inline
In-Reply-To: <p73r6tanmhk.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01-02-2007 12:30, Andi Kleen wrote:
> Simon Lodal <simonl@parknet.dk> writes:
>> Memory is generally not an issue, but CPU is, and you can not beat the CPU 
>> efficiency of plain array lookup (always faster, and constant time).

Probably for some old (or embedded) lean boxes used for
small network routers, with memory hungry iptables -
memory could be an issue.

> Actually that's not true when the array doesn't fit in cache.
> 
> The cost of going out to memory over caches is so large (factor 100 and more) 
> that often algorithms with smaller cache footprint can easily beat
> algorithms that execute much less instructions if it has less cache misses. 
> That is because not all instructions have the same cost; anything
> in core is very fast but going out to memory is very slow.
> 
> That said I think I agree with your analysis that a two level
> array is probably the right data structure for this and likely
> not less cache efficient than the hash table.

Strange - it seems you gave only arguments against this
analysis...

> And the worst memory consumption case considered by Patrick should
> be relatively unlikely.

Anyway, such approach, that most users do something
this (reasonable) way, doesn't look like good
programming practice.

I wonder, why not try, at least for a while, to do this
a compile (menuconfig) option with a comment:
recommended for a large number of classes. After hash
optimization and some testing, final decisions could be
made.

Regards,
Jarek P.
