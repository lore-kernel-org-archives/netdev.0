From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [NET]: rt_check_expire() can take a long time, add a cond_resched()
Date: Sat, 17 Nov 2007 13:56:08 +0100
Message-ID: <p73k5ohav4n.fsf@bingen.suse.de>
References: <200711150401.lAF41mSs021898@hera.kernel.org>
	<20071115193802.4ec64eef@laptopd505.fenrus.org>
	<473D131A.5000200@cosmosbay.com> <473D18A5.2090309@cosmosbay.com>
	<20071115215938.44233733@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, netdev@vget.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758626AbXKQM4W@vger.kernel.org>
In-Reply-To: <20071115215938.44233733@laptopd505.fenrus.org> (Arjan van de Ven's message of "Thu\, 15 Nov 2007 21\:59\:38 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven <arjan@infradead.org> writes:
>> > 
>> > Its not that cheap. The ChangeLog included my own numbers, on a
>> > Pentium M machine. (i686, 1.6 GHz, 1.5 GB ram)
>> > 
>> > Without "if (need_resched())" (so calling need_resched() X.XXX.XXX 
>> > times), each run takes 88ms
>> > 
>> > With the extra check (and *much* less function calls), each run
>> > takes 25ms

ms?!? The numbers sound wrong. Wrong unit? 

>> > 
>> 
>> Looking at cond_resched(), I think the extra cost comes from
>> "mov %esp,%edx ; and $0xffffe000,%edx" (current_thread_info())
>> 
>> I dont have oprofile numbers yet, but I suspect CPU may have some
>> delays to compute this pointer value, since %esp is probably 'busy'
>> because of the preceding "call"
>
> yeah the explicit reference makes the stack pointer tracking engine do a
> commit I suspect which then also creates a data dependency in the code
> flow.
>
> however... this is likely a good argument for making cond_resched() as a
> whole a #define (or inline) that does this test and then calls the out
> of line code (which then doesn't need to retest, so it avoids the
> double test)...

Disadvantage would be that might_sleep would be commonly skipped then
(unless you actually need to reschedule) 
But perhaps that's not a big issue.

-Andi
