From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/5] forcedeth: interrupt handling cleanup
Date: Sun, 07 Oct 2007 07:40:45 -0400
Message-ID: <4708C5BD.8090402@garzik.org>
References: <20071006151250.GA17020@havoc.gtf.org>	 <20071006151400.GB17488@havoc.gtf.org> <86802c440710062143x3bb801c3obb91292208073588@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42097 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221AbXJGLk4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 07:40:56 -0400
In-Reply-To: <86802c440710062143x3bb801c3obb91292208073588@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yinghai Lu wrote:
> On 10/6/07, Jeff Garzik <jeff@garzik.org> wrote:
>> commit a606d2a111cdf948da5d69eb1de5526c5c2dafef
>> Author: Jeff Garzik <jeff@garzik.org>
>> Date:   Fri Oct 5 22:56:05 2007 -0400
>>
>>     [netdrvr] forcedeth: interrupt handling cleanup
>>
>>     * nv_nic_irq_optimized() and nv_nic_irq_other() were complete duplicates
>>       of nv_nic_irq(), with the exception of one function call.  Consolidate
>>       all three into a single interrupt handler, deleting a lot of redundant
>>       code.
>>
>>     * greatly simplify irq handler locking.
>>
>>       Prior to this change, the irq handler(s) would acquire and release
>>       np->lock for each action (RX, TX, other events).
>>
>>       For the common case -- RX or TX work -- the lock is always acquired,
>>       making all successive acquire/release combinations largely redundant.
>>
>>       Acquire the lock at the beginning of the irq handler, and release it at
>>       the end of the irq handler.  This is simple, easy, and obvious.
>>
>>     * remove irq handler work loop.
>>
>>       All interesting events emanating from the irq handler either have
>>       their own work loops, or they poke a timer into action.
>>
>>       Therefore, delete the pointless master interrupt handler work loop.
>>
>>     Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
>>
>>  drivers/net/forcedeth.c |  325 +++++++++++-------------------------------------
>>  1 file changed, 77 insertions(+), 248 deletions(-)
>>
> any chance to create three verion irq handlers for ioapic, msi, msi-x...?
> 
> MACRO or inline function?

MSI-X already has its own separate interrupt handlers.  MSI and INTx 
call the same interrupt handling code, like the unmodified driver goes. 
  Creating an MSI-specific irq handler would not save very much AFAICS, 
but I might be missing something.

Do you have ideas/suggestions for a different method?

	Jeff



