From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Sun, 12 Aug 2007 12:35:27 +0200
Message-ID: <914eee40a2967ca153c28da4705722c4@kernel.crashing.org>
References: <20070808230733.GA17270@shell.boston.redhat.com> <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org> <46BAC2BE.1090106@redhat.com> <46BB508B.7050601@redhat.com> <alpine.LFD.0.999.0708091055080.25146@woody.linux-foundation.org> <1186683646.9669.20.camel@localhost> <a599bc5062d557db46496f0d7c7886b0@kernel.crashing.org> <1186912053.3852.9.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wjiang@resilience.com,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, heiko.carstens@de.ibm.com,
	linux-kernel@vger.kernel.org, ak@suse.de, cfriesen@nortel.com,
	netdev@vger.kernel.org, horms@verge.net.au,
	akpm@linux-foundation.org, Chuck Ebbert <cebbert@redhat.com>,
	davem@davemloft.net, zlynx@acm.org, Chris Snook <csnook@redhat.com>
To: schwidefsky@de.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933448AbXHLKgV@vger.kernel.org>
In-Reply-To: <1186912053.3852.9.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> Yes, though I would use "=m" on the output list and "m" on the input
>>> list. The reason is that I've seen gcc fall on its face with an ICE 
>>> on
>>> s390 due to "+m". The explanation I've got from our compiler people 
>>> was
>>> quite esoteric, as far as I remember gcc splits "+m" to an input
>>> operand
>>> and an output operand. Now it can happen that the compiler chooses 
>>> two
>>> different registers to access the same memory location. "+m" requires
>>> that the two memory references are identical which causes the ICE if
>>> they are not.
>>
>> The problem is very nicely described here, last paragraph:
>> <http://gcc.gnu.org/ml/gcc-patches/2007-07/msg01816.html>
>>
>> It's not a problem anymore in (very) recent GCC, although
>> that of course won't help you in the kernel (yet).
>
> So you are saying that gcc 3.x still has this problem ?

Yes.  A warning ("read-write constraint does not allow a register")
was added for GCC-3.4, but the fix/workaround is more recent
(4.2 I believe, perhaps it was backported to the 4.1 branch).

>>> I do not know if the current compilers still do this. Has
>>> anyone else seen this happen ?
>>
>> In recent GCC, it's actually documented:
>>
>> 	 The ordinary output operands must be write-only; GCC will assume 
>> that
>> 	the values in these operands before the instruction are dead and need
>> 	not be generated.  Extended asm supports input-output or read-write
>> 	operands.  Use the constraint character `+' to indicate such an 
>> operand
>> 	and list it with the output operands.  You should only use read-write
>> 	operands when the constraints for the operand (or the operand in 
>> which
>> 	only some of the bits are to be changed) allow a register.
>>
>> Note that last line.
>
> I see, thanks for the info.

My pleasure.


Segher
