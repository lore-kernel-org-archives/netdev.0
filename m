From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V2 net-next] udp: Neaten and reduce size of
 compute_score functions
Date: Mon, 01 Dec 2014 21:26:15 -0800
Message-ID: <1417497975.4894.16.camel@perches.com>
References: <1417484341.4894.6.camel@perches.com>
	 <1417489141.4442.24.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1417489760.4894.8.camel@perches.com>
	 <1417494546.4894.12.camel@perches.com>
	 <1417496925.5303.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0038.hostedemail.com ([216.40.44.38]:37576 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751060AbaLBF0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 00:26:18 -0500
In-Reply-To: <1417496925.5303.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-12-01 at 21:08 -0800, Eric Dumazet wrote:
> On Mon, 2014-12-01 at 20:29 -0800, Joe Perches wrote:
> > The compute_score functions are a bit difficult to read.
> > 
> > Neaten them a bit to reduce object sizes and make them a
> > bit more intelligible.
> > 
> > Return early to avoid indentation and avoid unnecessary
> > initializations.
> > 
> > (allyesconfig, but w/ -O2 and no profiling)
> 
> hmm... Not sure how you get such large numbers...

Nor I particularly, but I do with gcc 4.9.1

> > $ size net/ipv[46]/udp.o.*
> >    text    data     bss     dec     hex filename
> >   28680    1184      25   29889    74c1 net/ipv4/udp.o.new
> >   28756    1184      25   29965    750d net/ipv4/udp.o.old
[]
> Here I have :
> 
> # size net/ipv4/udp.o.*
>    text	   data	    bss	    dec	    hex	filename
>   21989	    616	      9	  22614	   5856	net/ipv4/udp.o.old
>   21957	    616	      9	  22582	   5836	net/ipv4/udp.o.new

Curious.  What gcc version?

with that 4.9.1 gcc version and a defconfig (x86-64) I get:

$ size net/ipv[46]/udp.o*
   text	   data	    bss	    dec	    hex	filename
  21328	    672	      9	  22009	   55f9	net/ipv4/udp.o.new
  21312	    672	      9	  21993	   55e9	net/ipv4/udp.o.old
  14463	    588	      2	  15053	   3acd	net/ipv6/udp.o.new
  14527	    588	      2	  15117	   3b0d	net/ipv6/udp.o.old

and defconfig x86-32:

$ size net/ipv[46]/udp.o*
   text	   data	    bss	    dec	    hex	filename
  19626	    324	      5	  19955	   4df3	net/ipv4/udp.o.new
  19706	    324	      5	  20035	   4e43	net/ipv4/udp.o.old
  14189	    300	      2	  14491	   389b	net/ipv6/udp.o.new
  14125	    300	      2	  14427	   385b	net/ipv6/udp.o.old

> With CONFIG_CC_OPTIMIZE_FOR_SIZE=y I even have an opposite result (code
> gets bigger after your patch)
> 
> # size net/ipv4/udp.o.*
>    text	   data	    bss	    dec	    hex	filename
>   17242	    600	      9	  17851	   45bb	net/ipv4/udp.o.old
>   17256	    600	      9	  17865	   45c9	net/ipv4/udp.o.new
> 
> Anyway, your patch looks fine to me, no matter what the code size is.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
