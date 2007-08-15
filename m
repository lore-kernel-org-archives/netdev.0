From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 20:31:25 +0200
Message-ID: <d4406222873856f472b9173a14a19aa2@kernel.crashing.org>
References: <46C2350A.1010807@redhat.com> <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <20070815081841.GA16551@osiris.boeblingen.de.ibm.com> <46C30540.2070603@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151941150.16414@enigma.security.iitk.ac.in> <20070815145207.GA23106@gondor.apana.org.au> <46C3253F.5090707@s5r6.in-berlin.de> <20070815162722.GD9645@linux.vnet.ibm.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Satyam Sharma <satyam@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	rpjday@mindspring.com, netdev@vger.kernel.org, ak@suse.de,
	cfriesen@nortel.com, Heiko Carstens <heiko.carstens@de.ibm.com>,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:38916 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658AbXHOUgd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 16:36:33 -0400
In-Reply-To: <20070815162722.GD9645@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> How does the compiler know that msleep() has got barrier()s?
>
> Because msleep_interruptible() is in a separate compilation unit,
> the compiler has to assume that it might modify any arbitrary global.

No; compilation units have nothing to do with it, GCC can optimise
across compilation unit boundaries just fine, if you tell it to
compile more than one compilation unit at once.

What you probably mean is that the compiler has to assume any code
it cannot currently see can do anything (insofar as allowed by the
relevant standards etc.)

> In many cases, the compiler also has to assume that 
> msleep_interruptible()
> might call back into a function in the current compilation unit, thus
> possibly modifying global static variables.

It most often is smart enough to see what compilation-unit-local
variables might be modified that way, though :-)


Segher

