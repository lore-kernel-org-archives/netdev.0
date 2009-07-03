From: Dave <kilroyd@googlemail.com>
Subject: Re: [PATCH] check spinlock_t/rwlock_t argument type on non-SMP builds
Date: Fri, 03 Jul 2009 20:02:01 +0100
Message-ID: <4A4E55A9.7090001@gmail.com>
References: <1246560291-8104-1-git-send-email-kilroyd@googlemail.com> <20090703073801.GA10191@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Kilroy <kilroyd@googlemail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f215.google.com ([209.85.219.215]:52748 "EHLO
	mail-ew0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756475AbZGCTCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 15:02:08 -0400
In-Reply-To: <20090703073801.GA10191@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> * David Kilroy <kilroyd@googlemail.com> wrote:
> 
>> When writing code for UP without CONFIG_DEBUG_SPINLOCK it's easy 
>> to get the first argument to the spinlock/rwlock functions wrong. 
>> This is because the parameter is not actually used in this 
>> configuration.
>>
>> Typically you will only find out it's wrong
>>  * by rebuilding with CONFIG_SMP or CONFIG_DEBUG_SPINLOCK
>>  * after you've submitted your beautiful patch series.
>>
>> The first means a long wait, and the latter is a bit late.
>>
>> Add typechecking on the first argument of these macro functions. 
>> Note that since the typecheck now references the variable, the 
>> explicit read is redundant and can be removed.
>>
>> This change causes compiler warnings in net/ipv4/route.c, as this 
>> passes NULL as the first argument in the UP configuration. Simply 
>> cast this.
> 
> Wondering - can the wrappers be moved from CPP land to C land by 
> turning them into inlines? (i havent checked all usages so there 
> might be some surprises, but by and large it ought to be possible.)

I thought about doing it that way. I decided not to because I suspected
it would be harder to verify that the behaviour is unchanged.

Also the _lock_irqsave functions output to the flags parameter (which
isn't a pointer) so that has to remain a macro.

If you'd really rather an inline version, I can spend some time looking
into it.


Dave.
