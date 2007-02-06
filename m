From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] HTB O(1) class lookup
Date: Tue, 6 Feb 2007 09:08:54 +0100
Message-ID: <20070206080854.GA1635@ff.dom.local>
References: <20070205101637.GB1863@ff.dom.local> <200702051814.13899.simonl@parknet.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org, lartc@mailman.ds9a.nl,
	Ingo Oeser <netdev@axxeo.de>
To: Simon Lodal <simonl@parknet.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:52853 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751519AbXBFIGB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 03:06:01 -0500
Content-Disposition: inline
In-Reply-To: <200702051814.13899.simonl@parknet.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 05, 2007 at 06:14:13PM +0100, Simon Lodal wrote:
> On Monday 05 February 2007 11:16, Jarek Poplawski wrote:
> > On 01-02-2007 12:30, Andi Kleen wrote:
> > > Simon Lodal <simonl@parknet.dk> writes:
> > >> Memory is generally not an issue, but CPU is, and you can not beat the
> > >> CPU efficiency of plain array lookup (always faster, and constant time).
> >
> > Probably for some old (or embedded) lean boxes used for
> > small network routers, with memory hungry iptables -
> > memory could be an issue.
> 
> Sure, but if they are that constrained they probably do not run HTB in the 
> first place.
> 
> We are talking about 4k initially, up to 256k worst case (or 512k if your 
> router is 64bit, unlikely if "small" is a priority).
> 
> > > And the worst memory consumption case considered by Patrick should
> > > be relatively unlikely.
> >
> > Anyway, such approach, that most users do something
> > this (reasonable) way, doesn't look like good
> > programming practice.
> 
> The current hash algorithm also assumes certain usage patterns, namely that 
> you choose classids that generate different hash keys (= distribute uniformly 
> across the buckets), or scalability will suffer very quickly. Even at 64 
> classes you would probably see htb_find() near the top of a profiling 
> analysis.
> 
> But I would say that it is just as unlikely as choosing 64 classids that cause 
> my patch to allocate all 256k.
> 
> In these unlikely cases, my patch only wastes passive memory, while the 
> current htb wastes cpu to a point where it can severely limit routing 
> performance.
> 
> 
> > I wonder, why not try, at least for a while, to do this
> > a compile (menuconfig) option with a comment:
> > recommended for a large number of classes. After hash
> > optimization and some testing, final decisions could be
> > made.
> 
> I decided not to do it because it would mean too many ifdefs 
> (ugly+unmaintanable code).

As a matter of fact Andi's recommentation is enough
for me. In his first message he wrote "probably the
right data structure for this", so I thought: why
not test and make sure. It should be easier without
removing current solution. But his second message
convinced me.

Generally I think 512k (or even 256k) should matter
and don't agree HTB is not for constrained ones. It
could be dangerous attitude if every module in the
kernel were so "generous". And it could be contagious:
others don't care - why should I?

Some time ago low memory requirements and possibility
to run on older boxes were strong arguments for linux.
Did we give it up to BSDs?

So I only wanted to make sure there would be a real
gain, because, for consistency, probably the same
model should be used with others (CBQ, HFSC).

Cheers,
Jarek P.
