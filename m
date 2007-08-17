From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 12:50:33 -0600
Message-ID: <46C5EDF9.3090507@nortel.com>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi> <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com> <18117.1287.779351.836552@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708161953310.30176@woody.linux-foundation.org> <18117.6495.397597.582736@cargo.ozlabs.ibm.com> <20070817035342.GA14744@gondor.apana.org.au> <alpine.LFD.0.999.0708171142550.3666@enigma.security.iitk.ac.in> <46C55E90.7010407@yahoo.com.au> <alpine.LFD.0.999.0708171431150.3666@enigma.security.iitk.ac.in> <46C56ADF.8010501@cyberone.com.au> <alpine.LFD.0.999.0708171612440.3666@enigm
 a.security.iitk.ac.in> <46C59717.4020108@cyberone.com.au> <alpine.LFD.0.999.0708170929580.30176@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nick Piggin <piggin@cyberone.com.au>,
	Satyam Sharma <satyam@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, zlynx@acm.org, rpjday@mindspring.com,
	jesper.juhl@gmail.com, segher@kernel.crashing.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:57225 "EHLO
	zcars04f.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492AbXHQSvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 14:51:00 -0400
In-Reply-To: <alpine.LFD.0.999.0708170929580.30176@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:

>  - in other words, the *only* possible meaning for "volatile" is a purely 
>    single-CPU meaning. And if you only have a single CPU involved in the 
>    process, the "volatile" is by definition pointless (because even 
>    without a volatile, the compiler is required to make the C code appear 
>    consistent as far as a single CPU is concerned).

I assume you mean "except for IO-related code and 'random' values like 
jiffies" as you mention later on?  I assume other values set in 
interrupt handlers would count as "random" from a volatility perspective?

> So anybody who argues for "volatile" fixing bugs is fundamentally 
> incorrect. It does NO SUCH THING. By arguing that, such people only show 
> that you have no idea what they are talking about.

What about reading values modified in interrupt handlers, as in your 
"random" case?  Or is this a bug where the user of atomic_read() is 
invalidly expecting a read each time it is called?

Chris
