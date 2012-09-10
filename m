From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [tcpdump-workers] Modular arithmetic
Date: Mon, 10 Sep 2012 11:25:24 +0200
Message-ID: <1347269124.1234.1326.camel@edumazet-glaptop>
References: <20120905213941.03c85968@arrowsmith>
	 <C71A36A8-08D2-4D3D-AF2B-EF89FEECE1A6@alum.mit.edu>
	 <20120906073615.693d14e0@arrowsmith>
	 <46AB14E3-73F4-41FA-8086-F1D663AF4549@alum.mit.edu>
	 <20120907074910.2df46817@arrowsmith>
	 <20120908030311.GM17289@tassilo.jf.intel.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B6FE4@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@linux.intel.com>,
	George Bakos <gbakos@alpinista.org>,
	tcpdump-workers@lists.tcpdump.org,
	Jay Schulist <jschlst@samba.org>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40450 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754552Ab2IJJZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 05:25:29 -0400
Received: by eekc1 with SMTP id c1so930780eek.19
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 02:25:28 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FE4@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-10 at 09:41 +0100, David Laight wrote:
> > On Fri, Sep 07, 2012 at 07:49:10AM +0000, George Bakos wrote:
> > > Gents,
> > > Any fundamental reason why the following (, etc.) shouldn't be
> > > included in net/core/filter.c?
> > >
> > >                 case BPF_S_ALU_MOD_X:
> > >                         if (X == 0)
> > >                                 return 0;
> > >                         A %= X;
> > >                         continue;
> > 
> > Copying netdev.
> > 
> > In principle no reason against it, but you may need to update
> > the various BPF JITs too that Linux now has too.
> 
> What about the other OS - eg all the BSDs?
> I had a vague idea that BPF was supposed to be reasonable portable.

Yes, does it mean BPF is frozen ?

Or is BSD so hard to update these days ?

modulus can be implemented using fallback to div and sub, I am not sure
libpcap should sense kernel support or not.

George, make sure libpcap optimizer correctly replaces MOD X  by AND (X
- 1) if X is a power of two.
