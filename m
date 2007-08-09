From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 09 Aug 2007 10:29:31 -0400
Message-ID: <46BB24CB.1040405@redhat.com>
References: <20070809131423.GA9927@shell.boston.redhat.com> <200708091441.28511.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965294AbXHIOav@vger.kernel.org>
In-Reply-To: <200708091441.28511.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> On Thursday 09 August 2007, Chris Snook wrote:
>> This patchset makes the behavior of atomic_read uniform by removing the
>> volatile keyword from all atomic_t and atomic64_t definitions that currently
>> have it, and instead explicitly casts the variable as volatile in
>> atomic_read().  This leaves little room for creative optimization by the
>> compiler, and is in keeping with the principles behind "volatile considered
>> harmful".
>>
> 
> Just an idea: since all architectures already include asm-generic/atomic.h,
> why not move the definitions of atomic_t and atomic64_t, as well as anything
> that does not involve architecture specific inline assembly into the generic
> header?
> 
> 	Arnd <><

a) chicken and egg: asm-generic/atomic.h depends on definitions in asm/atomic.h

If you can find a way to reshuffle the code and make it simpler, I personally am 
all for it.  I'm skeptical that you'll get much to show for the effort.

b) The definitions aren't precisely identical between all architectures, so it 
would be a mess of special cases, which gets us right back to where we are now.

	-- Chris
