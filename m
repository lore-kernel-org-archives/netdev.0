From: Simon Lodal <simonl@parknet.dk>
Subject: Re: [PATCH] HTB O(1) class lookup
Date: Mon, 5 Feb 2007 18:14:13 +0100
Message-ID: <200702051814.13899.simonl@parknet.dk>
References: <20070205101637.GB1863@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org, lartc@mailman.ds9a.nl,
	Ingo Oeser <netdev@axxeo.de>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from duen.parknet.dk ([217.116.235.14]:35846 "EHLO duen.parknet.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932922AbXBEROU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 12:14:20 -0500
In-Reply-To: <20070205101637.GB1863@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 February 2007 11:16, Jarek Poplawski wrote:
> On 01-02-2007 12:30, Andi Kleen wrote:
> > Simon Lodal <simonl@parknet.dk> writes:
> >> Memory is generally not an issue, but CPU is, and you can not beat the
> >> CPU efficiency of plain array lookup (always faster, and constant time).
>
> Probably for some old (or embedded) lean boxes used for
> small network routers, with memory hungry iptables -
> memory could be an issue.

Sure, but if they are that constrained they probably do not run HTB in the 
first place.

We are talking about 4k initially, up to 256k worst case (or 512k if your 
router is 64bit, unlikely if "small" is a priority).

> > And the worst memory consumption case considered by Patrick should
> > be relatively unlikely.
>
> Anyway, such approach, that most users do something
> this (reasonable) way, doesn't look like good
> programming practice.

The current hash algorithm also assumes certain usage patterns, namely that 
you choose classids that generate different hash keys (= distribute uniformly 
across the buckets), or scalability will suffer very quickly. Even at 64 
classes you would probably see htb_find() near the top of a profiling 
analysis.

But I would say that it is just as unlikely as choosing 64 classids that cause 
my patch to allocate all 256k.

In these unlikely cases, my patch only wastes passive memory, while the 
current htb wastes cpu to a point where it can severely limit routing 
performance.


> I wonder, why not try, at least for a while, to do this
> a compile (menuconfig) option with a comment:
> recommended for a large number of classes. After hash
> optimization and some testing, final decisions could be
> made.

I decided not to do it because it would mean too many ifdefs 
(ugly+unmaintanable code).


Regards
Simon
