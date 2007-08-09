From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Fri, 10 Aug 2007 01:02:13 +0200
Message-ID: <f571b4f940ec48e7984c7cdad6ac64f5@kernel.crashing.org>
References: <20070809132442.GA13042@shell.boston.redhat.com> <20070809143255.GA8424@linux.vnet.ibm.com> <46BB2A5A.5090006@redhat.com> <20070809150445.GB8424@linux.vnet.ibm.com> <46BB31A6.4080507@redhat.com> <3bfabd7472d6f019aa1880b14013f7a1@kernel.crashing.org> <46BB3ECF.2070100@redhat.com> <1abc2c621d6b62b3ac9f489d4d18806a@kernel.crashing.org> <46BB656D.6090408@redhat.com> <Pine.LNX.4.64.0708092123270.22584@anakin> <46BB6F65.8040204@redhat.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, heiko.carstens@de.ibm.com,
	horms@verge.net.au, linux-kernel@vger.kernel.org,
	rpjday@mindspring.com, ak@suse.de, netdev@vger.kernel.org,
	cfriesen@nortel.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, jesper.juhl@gmail.com,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-arch@vger.kernel.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	davem@davemloft.net, wensong@linux-vs.org, wjiang@resilience.com
To: Chris Snook <csnook@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759796AbXHIXD1@vger.kernel.org>
In-Reply-To: <46BB6F65.8040204@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>> So, why not use the well-defined alternative?
>>> Because we don't need to, and it hurts performance.
>> It hurts performance by implementing 32-bit atomic reads in assembler?
>
> No, I misunderstood the question.  Implementing 32-bit atomic reads in 
> assembler is redundant, because any sane compiler, *particularly* and 
> optimizing compiler (and we're only in this mess because of optimizing 
> compilers)

Oh please, don't tell me you don't want an optimising compiler.
And if you _do_ want one, well you're in this mess because you
chose C as implementation language and C has some pretty strange
rules.  Trying to use not-all-that-well-defined-and-completely-
misunderstood features of the language doesn't make things easier;
trying to use something that isn't even part of the language and
that your particular compiler originally supported by accident,
and that isn't yet an officially supported feature, and that on
top of it all has a track record of problems -- well it makes me
wonder if you're in this game for fun or what.

>  will give us that automatically without the assembler.

No, it does *not* give it to you automatically; you have to do
either the asm() thing, or the not-defined-at-all *(volatile *)&
thing.

> Yes, it is legal for a compiler to violate this assumption.  It is 
> also legal for us to refuse to maintain compatibility with compilers 
> that suck this badly.

So that's rm include/linux/compiler-gcc*.h then.  Good luck with
the intel compiler, maybe it works more to your liking.


Segher
