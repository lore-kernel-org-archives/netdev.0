From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] HTB O(1) class lookup
Date: 01 Feb 2007 12:30:47 +0100
Message-ID: <p73r6tanmhk.fsf@bingen.suse.de>
References: <200702010618.48692.simonl@parknet.dk>
	<45C183EF.2040701@trash.net> <200702010808.20416.simonl@parknet.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	lartc@mailman.ds9a.nl
To: Simon Lodal <simonl@parknet.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:53900 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422779AbXBAKaL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 05:30:11 -0500
In-Reply-To: <200702010808.20416.simonl@parknet.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Lodal <simonl@parknet.dk> writes:
> 
> Memory is generally not an issue, but CPU is, and you can not beat the CPU 
> efficiency of plain array lookup (always faster, and constant time).

Actually that's not true when the array doesn't fit in cache.

The cost of going out to memory over caches is so large (factor 100 and more) 
that often algorithms with smaller cache footprint can easily beat
algorithms that execute much less instructions if it has less cache misses. 
That is because not all instructions have the same cost; anything
in core is very fast but going out to memory is very slow.

That said I think I agree with your analysis that a two level
array is probably the right data structure for this and likely
not less cache efficient than the hash table.

And the worst memory consumption case considered by Patrick should
be relatively unlikely.

-Andi
