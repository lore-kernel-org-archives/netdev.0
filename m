From: Avi Kivity <avi@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 21:25:20 +0200
Message-ID: <4B311D20.7020400@redhat.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu> <4B3103B4.4070708@gmail.com> <4B3115C1.4070303@redhat.com> <4B311ADA.4000700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755201AbZLVT01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2009 14:26:27 -0500
In-Reply-To: <4B311ADA.4000700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/2009 09:15 PM, Gregory Haskins wrote:
> On 12/22/09 1:53 PM, Avi Kivity wrote:
>    
>> I asked why the irqfd/ioeventfd mechanisms are insufficient, and you did not reply.
>>
>>      
> BTW: the ioeventfd issue just fell through the cracks, so sorry about
> that.  Note that I have no specific issue with irqfd ever since the
> lockless IRQ injection code was added.
>
> ioeventfd turned out to be suboptimal for me in the fast path for two
> reasons:
>
> 1) the underlying eventfd is called in atomic context.  I had posted
> patches to Davide to address that limitation, but I believe he rejected
> them on the grounds that they are only relevant to KVM.
>    

If you're not doing something pretty minor, you're better of waking up a 
thread (perhaps _sync if you want to keep on the same cpu).  With the 
new user return notifier thingie, that's pretty cheap.

> 2) it cannot retain the data field passed in the PIO.  I wanted to have
> one vector that could tell me what value was written, and this cannot be
> expressed in ioeventfd.
>
>    

It would be easier to add data logging support to ioeventfd, if it was 
needed that badly.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

