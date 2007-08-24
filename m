From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH] i386: Fix a couple busy loops in mach_wakecpu.h:wait_for_init_deassert()
Date: Fri, 24 Aug 2007 21:26:57 +0100
Message-ID: <200708242126.58305.vda.linux@googlemail.com>
References: <46C2350A.1010807@redhat.com> <alpine.LFD.0.999.0708241812110.20322@enigma.security.iitk.ac.in> <Pine.LNX.4.64.0708241005360.20501@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Satyam Sharma <satyam@infradead.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, davem@davemloft.net, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au, wjiang@resilience.com,
	cfriesen@nortel.com, zlynx@acm.org, rpjday@mindspring.com,
	jesper.juhl@gmail.com, segher@kernel.crashing.org,
	Nick Piggin <nickpiggin@yahoo.com.au>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.229]:30160 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757259AbXHXU1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 16:27:07 -0400
Received: by hu-out-0506.google.com with SMTP id 19so626389hue
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2007 13:27:05 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0708241005360.20501@schroedinger.engr.sgi.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 24 August 2007 18:06, Christoph Lameter wrote:
> On Fri, 24 Aug 2007, Satyam Sharma wrote:
> > But if people do seem to have a mixed / confused notion of atomicity
> > and barriers, and if there's consensus, then as I'd said earlier, I
> > have no issues in going with the consensus (eg. having API variants).
> > Linus would be more difficult to convince, however, I suspect :-)
>
> The confusion may be the result of us having barrier semantics in
> atomic_read. If we take that out then we may avoid future confusions.

I think better name may help. Nuke atomic_read() altogether.

n = atomic_value(x);	// doesnt hint as strongly at reading as "atomic_read"
n = atomic_fetch(x);	// yes, we _do_ touch RAM
n = atomic_read_uncached(x); // or this

How does that sound?
--
vda
