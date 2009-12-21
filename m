From: Avi Kivity <avi@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Mon, 21 Dec 2009 19:05:06 +0200
Message-ID: <4B2FAAC2.4080007@redhat.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <4B2F978D.7010602@redhat.com> <4B2F9C85.7070202@gmail.com> <4B2FA42F.3070408@codemonkey.ws> <4B2FA4F2.8000401@redhat.com> <4B2FA8D4.3050206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751415AbZLURFo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Dec 2009 12:05:44 -0500
In-Reply-To: <4B2FA8D4.3050206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2009 06:56 PM, Gregory Haskins wrote:
>> I'm working on disappearing EOI exits on older hardware as well.  Same
>> idea as the old TPR patching, without most of the magic.
>>
>>      
> While I applaud any engineering effort that results in more optimal
> execution, if you are talking about what we have discussed in the past
> its not quite in the same league as my proposal.
>    

I don't doubt this for a minute.

> You are talking about the ability to optimize the final EOI if there are
> no pending interrupts remaining, right?  The problem with this approach
> is it addresses the wrong side of the curve: That is, it optimizes the
> code as its about to go io-idle.  You still have to take an extra exit
> for each injection during the heat of battle, which is when you actually
> need it most.
>    

No, it's completely orthogonal.  An interrupt is injected, the handler 
disables further interrupts and EOIs, then schedules the rest of the 
handling code.  So long as there as packets in the ring interrupts won't 
be enabled and hence there won't be any reinjections.

Different interrupt sources still need different interrupts, but as all 
of your tests have been single-interface, this can't be the reason for 
your performance.

-- 
error compiling committee.c: too many arguments to function

