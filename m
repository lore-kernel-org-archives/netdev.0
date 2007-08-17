From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Fri, 17 Aug 2007 10:52:37 +0200
Message-ID: <200708171052.39477.ak@suse.de>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, satyam@infradead.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764147AbXHQIzL@vger.kernel.org>
In-Reply-To: <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 17 August 2007 05:42, Linus Torvalds wrote:
> On Fri, 17 Aug 2007, Paul Mackerras wrote:
> > I'm really surprised it's as much as a few K.  I tried it on powerpc
> > and it only saved 40 bytes (10 instructions) for a G5 config.
>
> One of the things that "volatile" generally screws up is a simple
>
> 	volatile int i;
>
> 	i++;

But for atomic_t people use atomic_inc() anyways which does this correctly.
It shouldn't really matter for atomic_t.

I'm worrying a bit that the volatile atomic_t change caused subtle code 
breakage like these delay read loops people here pointed out.
Wouldn't it be safer to just re-add the volatile to atomic_read() 
for 2.6.23? Or alternatively make it asm(), but volatile seems more
proven.

-Andi
