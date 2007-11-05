From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash
 table
Date: Sun, 04 Nov 2007 20:24:54 -0800 (PST)
Message-ID: <20071104.202454.216339392.davem@davemloft.net>
References: <200711041326.38380.ak@suse.de>
	<20071104.135621.48992864.davem@davemloft.net>
	<200711050001.03699.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org, acme@redhat.com,
	jarkao2@o2.pl
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39290
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752861AbXKEEYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2007 23:24:55 -0500
In-Reply-To: <200711050001.03699.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Mon, 5 Nov 2007 00:01:03 +0100

> On Sunday 04 November 2007 22:56:21 David Miller wrote:
> > From: Andi Kleen <ak@suse.de>
> 
> > This makes a huge different as we have to set NR_CPUS to 4096
> > in order to handle the cpu numbering of some UltraSPARC-IV
> > machines.
> 
> Really? Hopefully you have a large enough stack then. There 
> are various users who put char str[NR_CPUS] on the stack
> and a few other data structures also get incredibly big with
> NR_CPUS arrays.

For the stack case there is one debugging case, and that's for
sprintf'ing cpusets.  That could be easily eliminated.

> If it's for sparse cpu ids -- x86 handles those with an 
> translation array.

I would rather not do this, so much assembler code indexes straight
into the per-cpu arrays.
