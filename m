From: "Chris Leech" <christopher.leech@intel.com>
Subject: Re: Question on IOAT
Date: Mon, 5 Feb 2007 10:24:02 -0800
Message-ID: <41b516cb0702051024i4982468dpc4c843d8627f6855@mail.gmail.com>
References: <200702051759.58928.olaf.kirch@oracle.com>
Reply-To: chris.leech@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Olaf Kirch" <olaf.kirch@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:22358 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933029AbXBESYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 13:24:08 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1373840uga
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 10:24:03 -0800 (PST)
In-Reply-To: <200702051759.58928.olaf.kirch@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/5/07, Olaf Kirch <olaf.kirch@oracle.com> wrote:

> Nowhere in the dma_async_*complete functions can I see any code
> that would sleep if the DMA is not yet complete. Am I missing something,
> or are we really busy-waiting on the DMA engine? Wouldn't this kind of
> defeat the purpose of freeing up the CPU from the chores of memcpying?

It is busy waiting, but only because the TCP socket use initiates the
DMA copies from the softirq and they have time to complete during the
switch back to application context.  Going back to sleep and creating
more context switching made things worse.  I'm working on seeing if
completion interrupts could be used with a better thought out
implementation, the performance implications aren't fully clear to me
yet.

For other uses, interrupts are probably desired.

> I also checked the code in ioatdma.c - I would have expected there to
> be some kind of interrupt handler that kicks the upper layers when a
> DMA operation completes. But the interrupt handler seems to be for
> error reporting exclusively...

It's just not there now, but it can be added easily, it's one bit in
the descriptor and a register read in the interrupt handler to see
which channel(s) need attention.

- Chris
