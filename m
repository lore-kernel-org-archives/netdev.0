From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Sun, 12 Aug 2007 02:54:16 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708120251570.30176@woody.linux-foundation.org>
References: <20070808230733.GA17270@shell.boston.redhat.com>
 <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org>
 <46BAC2BE.1090106@redhat.com> <46BB508B.7050601@redhat.com>
 <alpine.LFD.0.999.0708091055080.25146@woody.linux-foundation.org>
 <1186683646.9669.20.camel@localhost>  <a599bc5062d557db46496f0d7c7886b0@kernel.crashing.org>
  <alpine.LFD.0.999.0708112305170.30176@woody.linux-foundation.org>
 <1186912098.3852.11.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	wjiang@resilience.com, wensong@linux-vs.org,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	ak@suse.de, cfriesen@nortel.com, netdev@vger.kernel.org,
	horms@verge.net.au, akpm@linux-foundation.org,
	Chuck Ebbert <cebbert@redhat.com>, davem@davemloft.net,
	zlynx@acm.org, Chris Snook <csnook@redhat.com>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44630 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755298AbXHLJzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2007 05:55:04 -0400
In-Reply-To: <1186912098.3852.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sun, 12 Aug 2007, Martin Schwidefsky wrote:
> 
> The duplication "=m" and "m" with the same constraint is rather 
> annoying.

It's not only annoying, it causes gcc to generate bad code too. At least 
certain versions of gcc will generate the address *twice*, even if there 
is obviously only one address used.

If you have problems with "+m", you are often actually better off using 
just "m" and then adding a memory clobber. But that has other code 
generation downsides.

			Linus
